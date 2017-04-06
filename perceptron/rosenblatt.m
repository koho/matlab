function [W, WS, E] = rosenblatt(X, T, eta, varargin)
%A single-layer perceptron
% X   - NxM matrix whose columns represent variables and whose rows represent observations
% T   - Nx1 column vector of target classifications
% eta - Learning rate
% 
% Additional arguments
% epochs - Maximum number of iterations
% inst   - TRUE for instant output
%
% Return values
% W  - A weight vector
% WS - A weight matrix whose rows are weight vectors in each iteration
% E  - A error vector

%% =======================================================

% Defaults
if nargin < 4, epochs = Inf; else epochs = varargin{1}; end
if nargin < 5, inst = 0; else inst = varargin{2}; end

[n, m] = size(X);
X = [ones(n, 1) X];

% Initialization
W = zeros(1, m + 1);
WS = W;
iter = 1;

% Training
% Activation function: unit step function
while iter <= epochs
    
    errors = 0;
    % Optional
    % Select a random order of input vectors
%     ind = randperm(n);
%     X = X(ind, :);
%     T = T(ind, :);
    
    for i = 1:n
        % The output of the i-th sample
        y = hardlim(W * X(i,:)');
        
        % Update the weight vector
        % ------------------------------------
        % Y   T   UPDATE
        % ------------------------------------
        % 1   1   W(n + 1) = W(n)
        % 0   0   W(n + 1) = W(n)
        % 1   0   W(n + 1) = W(n) - eta * X(n)
        % 0   1   W(n + 1) = W(n) + eta * X(n)
        % ------------------------------------
        % These 4 cases can be summarized to
        % W(n + 1) = W(n) + eta * (T(i) - Y(i)) * X(n)
        W = W + eta * (T(i) - y) * X(i, :);
        
        % Record the number of errors
        errors = errors + double(T(i) ~= y);
    end
    
    E(iter, 1) = errors;
    E(iter, 2) = mae(hardlim(W * X')' - T);
    WS(iter, :) = W;
    
    % Set inst = 0 to suppress messages and graphics
    if inst
        disp(['Iter #', int2str(iter)]);
        fprintf('%s: %s\n', 'Weights', mat2str(W));
        fprintf('%s: %s\n\n', 'Errors', mat2str(E));
        
        plotdecision(W, X, T, iter);
        ploterror(E);
        pause(0.1);
    end
    
    if errors == 0
        break
    end
    iter = iter + 1;
end

if iter > epochs
    disp('Maximum epoch reached.');
end
end

function [] = plotdecision(W, X, T, epoch)
T = logical(T);
subplot(3, 1, 1);
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
        plot(X(~T,2), X(~T,3), 'bx', X(T, 2), X(T, 3), 'ks', 'MarkerFaceColor', 'r');
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

function [] = ploterror(E)
subplot(3, 1, 2);
plot(E(:, 1), 'b-o', 'LineWidth', 1, 'MarkerFaceColor', 'b');
xlabel('Iterations'), ylabel('Misclassifications');
title('Errors');
subplot(3, 1, 3);
plot(E(:, 2), 'r-o', 'LineWidth', 1, 'MarkerFaceColor', 'r');
xlabel('Epoch'), ylabel('Mean Absolute Error (mae)');
title('Performance');
end