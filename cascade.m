function [plabels] = cascade(x, y, test)
labels = unique(y);
sizes = [sum(y == labels(1)) sum(y == labels(2))];
[~,order] = sort(sizes);
large = find(y == labels(order(2)));
small = find(y == labels(order(1)));
q = 0;
nodes = cell(1);
while size(small, 1) < size(large, 1)
    q = q + 1;
    ind = randperm(size(large, 1), size(small, 1));
    classtree = fitensemble(x([large(ind); small],:), y([large(ind); small]),'AdaBoostM1',100,'Tree');
    p = predict(classtree, x(large,:));
    large(p == y(large)) = [];
    nodes{q} = classtree;
end
nodes{q + 1} = fitensemble(x([large; small],:), y([large; small]), 'AdaBoostM1',100,'Tree');
p = zeros(size(test, 1), q + 1);
for i = 1:(q + 1)
    p(:,i) = predict(nodes{i}, test);
end
plabels = repmat(labels(order(2)), size(test, 1), 1);
plabels(all(p == labels(order(1)), 2)) = labels(order(1));
end
