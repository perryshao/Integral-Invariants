function [net, K1] = train_libsvm(traindata, trainGID)
x = traindata;

gamma = 0.5;
% C      = 100.0;

K1 = Kernel(gamma, x, x);
n = size(K1, 1);
K1 = [(1:n)', K1];
net = svmtrain(trainGID, K1, '-t 4 -c 1 -b 1');
