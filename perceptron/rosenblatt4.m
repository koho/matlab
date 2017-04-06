function [wmax, maxcorrect] = rosenblatt4(X, T, eta, epoch, out)
if nargin < 5, out = 0; end
[n,m] = size(X);
w = zeros(1, m + 1);
X = [ones(n, 1) X];
X = X .* repmat(T, 1, m + 1);
maxcorrect = 0;
wmax = w;
for epoch = 1:epoch
    for i = 1:n
        if w * X(i,:)' <= 0
            w = w + eta * X(i, :);
        end
    end
    correct = sum(w * X' > 0);
    if correct > maxcorrect
        maxcorrect = correct;
        wmax = w;
    end
    if out
        plotdecision(wmax, X, T, epoch);
        pause(0.1);
    end
end
end

function [] = plotdecision(W, X, T, epoch)
X = X .* repmat(T, 1, size(X, 2));
%subplot(2, 1, 1);
switch size(X, 2) - 1
    case 1
        k = zeros(size(X(:, 2)));
        u = unique(X(:, 2));
        for i = 1:length(u)
            n = sum(X(:, 2) == u(i));
            k(X(:, 2) == u(i)) = 0:n-1;
        end
        plot(X(~T, 2), k(~T), 'bx', X(T, 2), k(T), 'ks', 'MarkerFaceColor', 'r');
        xlabel('x1');
        hold on;
        axis manual;
        plot([- W(1) / W(2), - W(1) / W(2)], ylim, 'm', 'LineWidth', 1);
        hold off;
    case 2
        plot(X(T == -1,2), X(T == -1,3), 'bx', X(T == 1, 2), X(T == 1, 3), 'ks', 'MarkerFaceColor', 'r');
        xlabel('x1'), ylabel('x2');
        hold on;
        axis manual;
        plot(xlim, - W(2) / W(3) * xlim - W(1) / W(3), 'm', 'LineWidth', 1);
        hold off;
    case 3
        disp();
    otherwise
        return
end
title('Perceptron');
marker = strsplit(num2str(unique(T')));
legend(marker{:});
text(0.1, 0.9, ['epoch: ', int2str(epoch)], 'VerticalAlignment', 'cap', 'HorizontalAlignment', 'center', 'Units', 'normalized');
end