function [beta table R] = regression(Y, X)
[n p] = size(X);
if n < p
    error('no enough observations');
end
Y = Y(:);
if size(Y, 1) ~= n
    error('Y must be a vector and must have the same number of rows as X.');
end
X = [ones(size(X,1), 1) X];
beta = inv(X' * X) * X' * Y;
yhat = X * beta;
SSR = (yhat - mean(Y))' * (yhat - mean(Y));
SSE = (Y - yhat)' * (Y - yhat);
SST = (Y - mean(Y))' * (Y - mean(Y));
Fa = SSR / SSE * (n - p - 1) / p;
R = sqrt(SSR/SST);
table = {'Source', 'SS', 'df', 'MS', 'F', 'p value', 'signif'};
if p > 1
    C = diag(inv(X' * X));
    SSJ = beta(2:end) .^ 2 ./ C(2:end);
    Fj = SSJ /  SSE * (n - p - 1);
    for k = 1:length(SSJ)
        table(k + 1,:) = {['x', num2str(k)], SSJ(k), 1, SSJ(k), Fj(k), fcdf(Fj(k), 1, n - p - 1, 'upper'), []};
    end
end
table(end + 1, :) = {'Regress', SSR, p, SSR/p, Fa, fcdf(Fa, p, n - p - 1, 'upper'), []};
table(end + 1, :) = {'Residual', SSE, n - p - 1, SSE/(n- p - 1), [], [], []};
table(end + 1, :) = {'Total', SST, n - 1, [], [], [], []};
F = [table{2:end - 2, 6}];
F(F <= 0.01) = 2;
F(F <= 0.05) = 1;
markers = {'*', '**'};
table(2:end - 2, 7) = markers(F);
end
