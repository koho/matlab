function [distances] = mahalanobis_distance2(A)
n = size(A, 2);
distances = zeros(n);
for i=1:n-1
    diff = repmat(A(:,i),1, n - i) - A(:,(i+1):n);
    %distances(i, (i+1):n) = sqrt(sum(diff' / cov(A') .* diff', 2));
    distances(i, (i+1):n) = diag(sqrt(diff' / cov(A') * diff));
end
distances = distances' + distances;