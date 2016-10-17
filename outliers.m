function [y yd] = outliers(x,op,alpha)
x=x(:);
y=x;yd=[];
if nargin < 2
    op='p';
end
if nargin < 3
    alpha=0.01;
end
n = length(y);
switch upper(op)
    case 'P'
        critical = 3 * std(y);
    case 'G'
        critical = 0;
    case 'T'
        critical = tinv(1-alpha,n-1)*sqrt(n/(n-1))*std(y);
    otherwise
        error('unknown option');
        return
end
[d i]= max(abs(y-mean(y)));
if d > critical
    yd = y(i);
    y(i) = [];
    [y del] = rds(y,op,alpha);
    yd = [yd del];
end
end
