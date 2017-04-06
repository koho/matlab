function [w] = rosenblatt2(X, T, eta)
[n,m] = size(X);
w = zeros(1, m + 1);
X = [ones(n, 1) X];
X = X .* repmat(T, 1, m + 1);
errors = 1;
while errors
    errors = 0;
    for i = 1:n
        if w * X(i,:)' <= 0
            w = w + eta * X(i, :);
            errors = 1;
        end
    end
end