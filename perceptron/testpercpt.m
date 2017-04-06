function [W, WS, E] = testpercpt(type)
switch type
    case -2
        iris = load('SPL');
        P = iris.SPL(:, 1:2)';
        T = iris.SPL(:, 3)';
        net = percpt_tool(P, T, [min(P, [], 2) max(P, [], 2)]);
        W = [net.b{1} net.iw{1}];
    case -1
        scores = load('scores.mat');
        classes = load('classes.mat');
        P = scores.X';
        T = classes.T';
        net = percpt_tool(P, T, [0 100]);
        W = [net.b{1} net.iw{1}];
    case 0
        X = round(normrnd(75, 10, 100, 1));
        X(X > 100) = [];
        T = X >= 60;
        save('S.mat', 'X');
        save('T.mat', 'T');
        [W, WS, E] = rosenblatt(X, T, 1, 40, 1);
    case 1
        scores = load('scores.mat');
        classes = load('classes.mat');
        [W, WS, E] = rosenblatt(scores.X, classes.T, 1, inf, 1);
    case 2
        iris = load('SPL');
        [W, WS, E] = rosenblatt(iris.SPL(:, 1:2), iris.SPL(:, 3), 1, inf, 1);
    case 3
        % TODO
%         X = normrnd(75, 10, 100, 3);
%         T = X(:, 1) >= 60 & X(:, 2) >= 60 & X(:, 3) >= 60;
%         [W, WS, E] = rosenblatt(X, T, 0.2);
    case 4
        % OR GATE
        X = [0 0
             0 1
             1 0
             1 1];
         T = [0 1 1 1]';
         [W, WS, E] = rosenblatt(X, T, 0.2, inf, 1);
    case 5
        % AND GATE
         X = [1 1
             0 0
             1 0
             0 1];
         T = [1 0 0 0]';
         [W, WS, E] = rosenblatt(X, T, 0.2, inf, 1);
    otherwise
        error('unknown option');
end

function [net] = percpt_tool(P, T, S)
% Obsoleted in R2010b
net = newp(S, 1);
% net = perceptron;
net.trainParam.epochs = 2000;
net.trainFcn = 'trainb';
net = train(net, P, T);
Y = sim(net, P);
plotpv(P, Y);
plotpc(net.iw{1}, net.b{1});