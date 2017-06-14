function [f] = lof(x, k)
n = size(x, 1);
dist = zeros(n);
for i = 1:(n-1)
    dist(i, (i + 1):n) = sqrt(sum((repmat(x(i,:), n - i, 1) - x((i + 1):n,:)) .^ 2, 2));
end
dist = dist + dist';
kdist = zeros(n, 1);
nk = zeros(n, 1);
for i = 1:n
    d = sort(dist(i,:));
    kdist(i) = d(k + 1);
    ind = find(dist(i,:) <= d(k + 1));
    indMinPts(i,1:length(ind)-1) = ind(ind ~= i);
    distMinPts(i,1:length(ind)-1) = dist(i,indMinPts(i,1:length(ind)-1));
    nk(i) = length(ind)-1;
end
kdist1 = [0; kdist];
kdistmat = kdist1(indMinPts + 1);
rd = max(kdistmat, distMinPts);
lrd = nk ./ sum(rd, 2);
lrd1 = [0; lrd];
f = sum(lrd1(indMinPts + 1), 2) ./ nk ./ lrd;
