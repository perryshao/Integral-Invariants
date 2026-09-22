function net = train_dagsvm(traindata,trainGID)
x = traindata;
n = size(traindata,1);
[C,IA,~] = unique(trainGID,'rows','R2012a');
y = -1*ones(n,C(end));
for i = 1:size(IA,1)-1
    y(IA(i):(IA(i+1)-1),i) = 1;
end
y(IA(i+1):end,i+1) = 1;

% create tutor
kernel = rbf(0.5);
C      = 100.0;
tutor  = smosvctutor;   % this means we use the SMO training algorithm
net    = dagsvm;        % this means we use the DAG-SVM algortihm to combine
                        % the outputs of a number of 2-class networks

net = train(net, tutor, x, y, C, kernel);