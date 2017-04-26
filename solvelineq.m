function [answers] = solvelineq(z, p)
if p == 1
    answers = z;
    return
end
answers = [];
for i = 0:z
    if z - i < 0, break; end
    a = solvelineq(z - i, p - 1);
    answers = [answers; repmat(i, size(a, 1), 1) a];
end
