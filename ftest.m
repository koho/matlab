function [F p] = ftest(x, y, tail)
x=x(:);y=y(:);
n1=length(x);n2=length(y);
F = var(x)/var(y);
switch tail
    case -1
        p = fcdf(F, n1-1, n2-1);
    case 0
        p = 2 * min(fcdf(F, n1-1, n2-1), fcdf(F, n1-1,n2-1, 'upper'));
    case 1
        p = fcdf(F, n1 - 1, n2 - 1, 'upper');
    otherwise
        error('invalid tail selected');
end
end
