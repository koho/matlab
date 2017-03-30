function [w] = rosenblatt2(X, T, eta)
[n,m] = size(X);
w = zeros(1, m + 1);
X = [ones(n, 1) X];
X = X .* repmat(T, 1, m + 1);
errors = 1;
maxrunlength = 0;
w0 = 0;
C=0;
while errors
    errors = 0;
    C=C+1;
    runlength = 0;
    pre = -1;
    for i = 1:n
        if w * X(i,:)' <= 0
            w = w + eta * X(i, :);
            errors = 1;
            if pre == 1
                if runlength > maxrunlength
                    w0 = w;
                    maxrunlength = runlength;
                    runlength = 0;
                end
            end
        else
            runlength = runlength + 1;
            pre = 1;
        end
    end
end
