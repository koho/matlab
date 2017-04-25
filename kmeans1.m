function [centroids, cluster, distances, EC, EL, SSE] = kmeans1(x, k, varargin)
%KMEANS1 Partition observations into k clusters based on Lloyd's algorithm.
%   x      - nxp matrix whose columns represent variables and whose rows
%           represent observations.
%   k      - the desired number of clusters.
%   epoch  - the maximum number of iterations.
%   output - graphic output.

if nargin < 3, epoch = 100; else epoch = varargin{1}; end
if nargin < 4, output = 0; else output = varargin{2}; end

[n, p] = size(x);

% Initialize centroids randomly.
centroids = x(randperm(n, k), :);

% Initialize book keeping vars.
iteration = 0;
oldCentroids = NaN(k, p);
EC = NaN(size(centroids));
EL = zeros(n, 1);

%% Main k-means algorithm
while ~isequal(oldCentroids, centroids) && iteration < epoch
    % Save old centroids for convergence test.
    oldCentroids = centroids;
    iteration = iteration + 1;
    
    % Assign labels to each datapoint based on centroids.
    [cluster, distances] = getLabels(x, centroids);
    
    % Record intermediate values.
    EC(:, :, iteration) = centroids;
    EL(:, iteration) = cluster;
    SSE(iteration) = sum(distances .^ 2);
    
    if output
        plotcluster(x, centroids, cluster, SSE, iteration);
    end
    
    % Assign centroids based on datapoint labels.
    centroids = getCentroids(x, cluster, oldCentroids);
end
end

%% Assign each observation to the cluster
function [labels, dists] = getLabels(x, centroids)
% Return a label for each point of data in x.
%k = size(centroids, 1);
%distances = zeros(size(x, 1), k);

% Calculate the euclidean distance between x and centroids.
%for i = 1:k
%    distances(:, i) = sqrt(sum((x - repmat(centroids(i, :), size(x, 1), 1)) .^ 2, 2));
%end
% For each element in x, chose the closest centroid.
% Make that centroid the element's label.
% c_i := arg \min_j ||x_i - \mu_j||^2.
%[dists, labels] = min(distances, [], 2);
[dists, labels] = min(sqrt(repmat(dot(centroids, centroids, 2)', size(x, 1), 1) + ...
        repmat(dot(x, x, 2), 1, size(centroids, 1)) - 2 * x * centroids'), [], 2);
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
