function [stat p] = chisq(x,pvar,tail)
x=x(:);
n = length(x);
stat = (n-1)* var(x)/ pvar;
switch tail
    case -1
        p = chi2cdf(stat, n -1);
    case 0
        p = 2 * min(chi2cdf(stat, n-1), chi2cdf(stat, n - 1, 'upper'));
    case 1
        p = chi2cdf(stat, n-1, 'upper');
    otherwise
        error('invalid tail selected');
end
end
