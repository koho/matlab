function [distances] = jackknife2(X)
covmat = jackknife(@cov, X');
[p,n] = size(X);
for i = 1:n
    diff = repmat(X(:,i), 1, n) - X;
    c = reshape(covmat(i,:), p, p);
    distances(i, 1:n) = sqrt(sum(diff' / c .* diff', 2 ));
end