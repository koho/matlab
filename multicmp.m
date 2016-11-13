function [table] = multicmp(A)
alpha = [0.05 0.01];
M = mean(A, 'omitnan');
N = sum(~isnan(A));
if length(unique(N)) > 1
    method = 'S';
else
    method = 'LSD';
end
n = sum(N);
[r, nlevel] = size(A);
if nlevel < 2
    error('levels must be greater than 1');
end
extendedM = repmat(M, r, 1);
extendedM(isnan(A)) = 0;
A(isnan(A)) = 0;  
MSE = trace((A - extendedM)' * (A - extendedM)) / (n - nlevel);
[M, I] = sort(M, 2, 'descend');
table = cell(nlevel + 1, nlevel + 2);
for k = 1:nlevel
    table{k + 1, 1} = ['A', num2str(I(k))];
    table{k + 1, 2} = num2str(M(k));
    table{1, k + 2} = ['A', num2str(I(nlevel + 1 - k))];
end
table{1,1} = 'levels';
table{1, 2} = 'mean';
for i = 1:nlevel
    markers = {};
    for j = i + 1:nlevel
        diff = M(i) - M(j);
        MOE = sqrt(MSE * (1/N(I(i)) + 1/N(I(j))));
        if strcmp(method, 'LSD')
            C = tinv(1 - alpha, n - nlevel) * MOE;
        elseif strcmp(method, 'S')
            C = sqrt((nlevel - 1) * finv(1 - alpha, nlevel - 1, n - nlevel)) * MOE;
        else
            error('unknown method');
        end
        if diff >= C(2)
            marker = '**';
        elseif diff >= C(1)
            marker = '*';
        else
            marker = [];
        end
        markers{end + 1} = [num2str(diff), marker];
    end
    markers = fliplr(markers);
    for k = 1:length(markers)
        table{i + 1, k + 2} = markers{k};
    end
end
end
