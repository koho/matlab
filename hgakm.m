function [centers, labels, genFit, genBest, genMSSE, genBSSE] = hgakm(x, k, epoch, popsize, pcross, pmutate, chaos)
p = size(x, 2);
genFit = zeros(epoch + 1, 2);
genBest = zeros(epoch + 1, p * k);
genMSSE = zeros(epoch + 1, 1);
genBSSE = zeros(epoch + 1, 1);
gen = 0;
population = initialize(x, k, popsize);
while 1
    sumd = zeros(size(population, 1), 1);
    sse = zeros(size(population, 1), 1);
    for i = 1:size(population, 1)
        centroids = population(i, :);
        centroids = reshape(centroids, p, k)';
        oldCentroids = NaN(k, p);
        while ~isequal(oldCentroids, centroids)
            oldCentroids = centroids;
            [cluster, dist] = getLabels(x, centroids);
            sumd(i) = sum(dist);
            sse(i) = sum(dist .^ 2);
            % Assign centroids based on datapoint labels.
            centroids = getCentroids(x, cluster, oldCentroids);
        end
        centroids = centroids';
        population(i, :) = centroids(:)';
    end
    
    gen = gen + 1;
    fitness = 1 / (1 + sumd);
    [fmax, nmax] = max(fitness);
    genFit(gen, 1:2) = [mean(fitness) fmax];
    genBest(gen, :) = population(nmax, :);
    genMSSE(gen) = mean(sse);
    genBSSE(gen) = sse(nmax);
    if gen > epoch
        break
    end
    
    %% GA Operation
    childPopulation = zeros(popsize + mod(popsize, 2), size(population, 2));
    for i = 1:2:popsize
        parentIndex = selection(fitness, 2);
        child = crossover(population, parentIndex, pcross);
        child = mutation(child, pmutate, min(x), max(x));
        
        childPopulation([i i + 1], :) = child;
    end
    % chaos
    U = rand(size(childPopulation)) .* 0.2;
    for j = 2:size(U, 1)
        U(j, :) = chaos.u * U(j - 1, :) .* (1 - U(j - 1, :)); 
    end
    childPopulation = childPopulation + chaos.t * U;
    population = childPopulation;
end
genBest = reshape(genBest', p, k, gen);
genBest = permute(genBest, [2 1 3]);
centers = genBest(:, :, end);
labels = getLabels(x, centers);
end

%%
function [population] = initialize(x, k, numPopulation)
[n, p] = size(x);
population = zeros(numPopulation, p * k);
for i = 1:numPopulation
    centroids = x(randperm(n, k), :);
    labels = getLabels(x, centroids);
    centroids = getCentroids(x, labels, centroids)';
    population(i, :) = centroids(:)';
end
end

%%
function [parentIndex] = selection(fitness, nParents)
parentIndex = zeros(1, nParents);
cumfit = cumsum(fitness);
for i = 1:nParents
    parentIndex(i) = find(rand < cumfit / cumfit(end), 1);
end
end

%% Single-point crossover
function [child] = crossover(population, parent, pcross)
% child = zeros(2, size(population, 2));
% d = 0.25;
% if rand < pcross
%     a = rand(2, size(population, 2)) * (1 + 2 *d) - d;
%     child = repmat(population(parent(1), :), 2, 1) + a .* ...
%         repmat(population(parent(2), :) - population(parent(1), :), 2, 1);
% else
%     child(1, :) = population(parent(1), :);
%     child(2, :) = population(parent(2), :);
% end

ngene = size(population, 2);
child = zeros(2, ngene);
if rand < pcross
    crossPoint = round(rand * (ngene - 2)) + 1; % Randomly chosen cross-over point between [1, ngene - 1].
    child(1, :) = [population(parent(1), 1:crossPoint) population(parent(2), crossPoint + 1:ngene)];
    child(2, :) = [population(parent(2), 1:crossPoint) population(parent(1), crossPoint + 1:ngene)];
else
    child(1, :) = population(parent(1), :);
    child(2, :) = population(parent(2), :);
end
end

%%
function [newPop] = mutation(population, pmutate, xmin, xmax)
[n, ngene] = size(population);
xmin = repmat(xmin, 1, ngene / size(xmin, 2));
xmax = repmat(xmax, 1, ngene / size(xmax, 2));
newPop = population;
for i = 1:n
    if rand < pmutate
        mutPoint = round(rand * (ngene - 1)) + 1;
        theta = 2 * rand - 1;
        if theta >= 0
            newPop(i, mutPoint) = newPop(i, mutPoint) + (xmax(mutPoint) - newPop(i, mutPoint)) * theta;
        else
            newPop(i, mutPoint) = newPop(i, mutPoint) + (newPop(i, mutPoint) - xmin(mutPoint)) * theta;
        end
    end
end
end

%% Calculate fitness
function [fitness] = getFitness(x, k, population, nbits)
nPop = size(population, 1);
sumd = zeros(nPop, 1);
p = size(x, 2);
for i = 1:nPop
    centroids = decode(population(i, :), min(x), max(x), nbits);
    centroids = reshape(centroids, p, k)';
    [~, dist] = getLabels(x, centroids);
    sumd(i) = sum(dist);
end
fitness = 1 / (1 + sumd);
end

%% Assign each observation to the cluster
function [labels, dists] = getLabels(x, centroids)
% Return a label for each point of data in x.
k = size(centroids, 1);
distances = zeros(size(x, 1), k);

% Calculate the euclidean distance between x and centroids.
for i = 1:k
    distances(:, i) = sqrt(sum((x - repmat(centroids(i, :), size(x, 1), 1)) .^ 2, 2));
end
% For each element in x, chose the closest centroid.
% Make that centroid the element's label.
% c_i := arg \min_j ||x_i - \mu_j||^2.
[dists, labels] = min(distances, [], 2);
end

%% Calculate the new centroids
function [centroids] = getCentroids(x, labels, oldCentroids)
k = length(unique(labels));
% Each centroid is the mean of the points that have that centroid's label.
for i = 1:k
    oldCentroids(i, :) = mean(x(labels == i, :));
end
centroids = oldCentroids;
end
