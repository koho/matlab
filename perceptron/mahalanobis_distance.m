function [distances] = mahalanobis_distance(A)
n = size(A, 2);
distances = zeros(n);
for i=1:n-1
    %diff = A(:,i) * ones(1, n - i) - A(:,(i+1):n);
    %diff = bsxfun(@minus, A(:,i), A(:,(i+1):n));
    diff = repmat(A(:,i), 1, n - i) - A(:, (i+1):n);
    distances(i,(i+1):n) = sqrt(sum(diff' / cov(A') .* diff', 2));
end
distances = distances'+ distances;