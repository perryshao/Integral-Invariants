function [confusion_matrix, test_loglik, I] = mhmm_classifier_cluster(traindata, trainGID, testdata, testGID)
O = size(traindata{1}, 1); % Number of coefficients in a vector
nex = length(traindata);        % Number of sequences
M = 2;          % Number of mixtures
Q = 6;          % Number of states

cov_type = 'full';
cov_prior = 0.01;
class_num = length(unique(trainGID));
cluster_num = zeros(class_num, 1);

for i = 1:class_num
    class_data = traindata(trainGID == i);
    % cluster first
    delta = 0.05;
    [clustMembsCell, C_distance] = Spec_Clustering(class_data', 4, 3, delta);
    cluster_num(i) = length(clustMembsCell);
    for j = 1:cluster_num(i)
        data = class_data(clustMembsCell{j});
        % initial guess of parameters
        prior0 = normalise(rand(Q, 1));
        transmat0 = mk_stochastic(rand(Q, Q));

        [mu0, Sigma0] = mixgauss_init(Q * M, data, cov_type);
        mu0 = reshape(mu0, [O Q M]);
        Sigma0 = reshape(Sigma0, [O O Q M]);
        mixmat0 = mk_stochastic(rand(Q, M));

        [LL{i, j}, prior{i, j}, transmat{i, j}, mu{i, j}, Sigma{i, j}, mixmat{i, j}] = ...
            mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 100, 'cov_type', cov_type, 'cov_prior', cov_prior);

        loglik{i, j} = mhmm_logprob(data, prior{i, j}, transmat{i, j}, mu{i, j}, Sigma{i, j}, mixmat{i, j})
    end
end
%% get the loglik with test data
nex = length(testdata);
class_num = length(unique(testGID));
test_loglik = zeros(nex, class_num);
for i = 1:nex
    for j = 1:class_num
        fprintf ('the %d samples/%d class--hmm recognition for integral descriptor...%2.2f%%\n', i, j, (class_num * (i - 1) + j) * 100 / (nex * class_num));
        data = testdata{i};
        test_loglik_temp = zeros(cluster_num(j), 1);
        for m = 1:cluster_num(j)
            test_loglik_temp(m) = mhmm_logprob(data, prior{j, m}, transmat{j, m}, mu{j, m}, Sigma{j, m}, mixmat{j, m});
        end
        test_loglik(i, j) = max(test_loglik_temp);
    end
end
[~, I] = max(test_loglik, [], 2); % sum up the recognition accurate ratio

for i = 1:class_num
    for j = 1:class_num
        confusion_matrix(i, j) = length(find(testGID == i & I == j));
    end
end
