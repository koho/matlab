function [centers, cluster] = kmeans1(x, k, epoch)
[n, p] = size(x);
centers = x(randperm(n, k), :);
preCenters = zeros(k, p);
while ~all(preCenters - centers == 0)
dists = calcDist(x, centers);
[minDist, cluster] = min(dists, [], 2);
centers = calcMean(x, c);
end
end

function [distances] = calcDist(x, c)
% Calculate the distances between x and each point in c
k = size(c, 1);
distances = zeros(size(x, 1), k);
for i = 1:k
    distances(:, i) = sqrt(sum((x - repmat(c(i, :), size(x, 1), 1)) .^ 2, 2));
end
end

function [means] = calcMean(x, c)
cluster = unique(c);
means = zeros(length(cluster), size(x, 2));
for k = cluster
    means(k, :) = mean(x(c == k,:));
end
end
