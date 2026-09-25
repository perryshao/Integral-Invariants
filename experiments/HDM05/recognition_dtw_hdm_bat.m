% modified to support running in occlusion situation -- modified by perry
clearvars;
% delete *.mat
%% define the experiment times and class numbers
% noise_level = [0.15 0.1 0.08 0.06 0.04 0.02];
noise_level = 0;
EXPERIMENT_TIMES = length(noise_level);
% EXPERIMENT_TIMES = 5;% repeated times of experiment
CLASS_NUM = 16; % class numbers for classification task
SAMPLES_NUM = 8; % training samples numbers
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'c3d_data_bat_16classes/';  % LOCATION OF C3D FILES
file_ext = '.c3d';
folder_content = dir(BAT_FOLDER);
class_num = size(folder_content, 1);
class_num = class_num - 2;
class_array = 1:class_num;
K = randperm(class_num);
CLASS_SELECTED = class_array(K(1:CLASS_NUM));
distance_matrix_interg = cell(1, EXPERIMENT_TIMES);
confusion_matrix_interg = cell(1, EXPERIMENT_TIMES);
distance_matrix_diff = cell(1, EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1, EXPERIMENT_TIMES);
recog_ratio_diff = zeros(1, EXPERIMENT_TIMES);
recog_ratio_interg = zeros(1, EXPERIMENT_TIMES);

%% define the joint name
RANK = 'RANK'; LANK = 'LANK'; RKNE = 'RKNE';
LKNE = 'LKNE'; T10 = 'T10'; C7 = 'C7';
RFHD = 'RFHD'; LSHO = 'LSHO'; RSHO = 'RSHO';
LELB = 'LELB'; RELB = 'RELB'; LWRA = 'LWRA';
RWRA = 'RWRA'; LFWT = 'LFWT'; RFWT = 'RFWT';
STRN = 'STRN'; ENSEMBLE = 'ENSEMBLE';
% joints_no = {LWRA,RWRA,LANK,RANK,...
%              LELB,RELB,LKNE,RKNE,RFHD};
% joints_no = {LWRA,RWRA,LANK,RANK,LSHO,...
%              LELB,RELB,LKNE,RKNE,RSHO,T10,STRN,C7,RFHD};
joints_no = {LWRA, RWRA, LANK, RANK, LSHO, ...
             LELB, RELB, LKNE, RKNE, RSHO, T10, C7, RFHD};
ROOT = ENSEMBLE;
ensemble_no = {ENSEMBLE};
gamma = 0.5;
for experiment_num = 1:EXPERIMENT_TIMES
    %%  generate random class samples and random training samples
    % reset random seeds
    rand('state', sum(100 * clock)); %#ok<RAND>
    randn('state', sum(100 * clock)); %#ok<RAND>
    random_seed = rand(1, SAMPLES_NUM);

    %% load targets of joints and preprocess and descriptor computation

    load_c3d_bat(joints_no, random_seed, CLASS_SELECTED, BAT_FOLDER);
    preprocess_bat(joints_no);

    %% loading the original data
    %       copyfile('mat/*.*','../HDM05EvaluatingCode/','f');
    %       add_noise_bat(joints_no,noise_level(experiment_num))

    %% shuffling the whole dataset
    fprintf ('shuffling the dataset...\n');
    shuffle_sort = ['bd'; 'bk'; 'dg'; 'mm'; 'tr'];
    [subjectID_DB, subjectID_SAMPLES] = shuffle_db(joints_no, shuffle_sort);
    %%  get the average of ensemble trajectories
    ensemble_bat(joints_no);
    %%  get relative descriptions of LWRA-LELB for database
    fprintf ('generate the relative descriptor...\n');
    [INTEGRATE_DES, INTEGRATESAMPLES_DES] = relative_descrip_bat(joints_no, ROOT);
    preprocess_bat(ensemble_no);
    %% pick up the most informative joints
    %     mj = most_informative(joints_no);
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor_integral(ROOT);
    %     gene_descriptor_integral_mj(joints_no,mj);
    %     mj_samples = most_informative_samples(joints_no);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_integral_samples(ROOT);
    %     gene_descriptor_integral_samples_mj(joints_no,mj_samples);
    %     %% shuffling the whole dataset
    %     fprintf ('shuffling the dataset...\n');
    %     shuffle_sort = [ 1 3 5;
    %                      2 4 0];
    %     [subjectID_DB subjectID_SAMPLES] = shuffle_db(markers,shuffle_sort);
    %     shuffle_des(STRN,shuffle_sort,subjectID_DB, subjectID_SAMPLES);
    load ([ROOT '_des.mat']);
    load ([ROOT 'samples_des.mat']);
    %     load (['MJ' '_des.mat']);
    %     load (['MJ' 'samples_des.mat']);
    %% Retrieval test based on Rank-one similarity decomposition
    fprintf(1, 'loading training data...\n');
    load ([ROOT, '.mat']); load ([ROOT, 'samples.mat']);
    descrip_flag = 6;
    [ClusterDescriptor, ClusterID] = ClusterAllData_JointFeatures(joints_no, descrip_flag);
    ClusterData = RankOneDecom_Feaures(ClusterDescriptor, joints_no, descrip_flag);

    Q_num = 20; % the number of query data
    [Qdata, QueryID] = PickupQuery(ClusterData, ClusterID, Q_num); % pick up the query data randomly with required number from dataset
    Recall = zeros(Q_num, 11); % initial value, 0.11-0.22-0.33...0.99,1
    Precision = zeros(Q_num, 11); % initial value, 0.11-0.22-0.33...0.99,1
    for i = 1:Q_num
        Recall(i, 1) = 1 / length(ClusterData(ClusterID == QueryID(i)));
        [Query_Indx, Q_distance] = Query_distance_RankOne(Qdata{i}, ClusterData, joints_no);
        Precision(i, 1) = 1;
        for j = 2:11 % initial value, 0.11-0.22-0.33...0.99,1
            fprintf('Retrievaling the data....%f%%\n', j / 11 * 100);
            if j == 11
                Recall(i, j) = 1;
            else
                Recall(i, j) = 0.11 * (j - 1);
            end
            Clustered_Indx = 0; %% not important parameter that can be ignore here
            [Retrieved_Data, Retrieved_Indx] = Retrieval_data(Query_Indx, QueryID(i), ...
                                                              Clustered_Indx, ClusterData, ClusterID, Recall(i, j));
            Relevant_Indx = find(ClusterID == QueryID(i));
            Precision(i, j) = length(intersect(Relevant_Indx, Retrieved_Indx)) / length(Retrieved_Indx);
        end
    end
    drawPRC(Recall, Precision);
    %% clustering and retrieval based on DTW of hierarchical descriptor
    fprintf(1, 'loading training data...\n');
    load ([ROOT, '.mat']); load ([ROOT, 'samples.mat']);
    [ClusterRawData, ClusterData, ClusterID] = ClusterAllData(TRAJDB, TRAJSAMPLES, ...
                                                              TRAJDB_DES, TRAJSAMPLES_DES, INTEGRATE_DES, INTEGRATESAMPLES_DES);
    delta = 2;
    [Clustered_Indx, Ctrs, C_distance] = Spec_Clustering(ClusterData, CLASS_NUM, 3, delta);

    cluster_num = 50; Average_accuracy = 0;
    for i = 1:cluster_num
        [Clustered_Indx, Ctrs, C_distance] = Spec_Clustering(ClusterData, CLASS_NUM, 3, delta, C_distance);
        Clustered_accuracy = Get_ClusterAccuracy(Clustered_Indx, ClusterID);
        Average_accuracy = Clustered_accuracy + Average_accuracy;
    end
    Average_accuracy = Average_accuracy / cluster_num;

    Plot_Cluster(ClusterRawData, ClusterID, Clustered_Indx);

    Q_num = 20; % the number of query data
    [Qdata, QueryID] = PickupQuery(ClusterData, ClusterID, Q_num); % pick up the query data randomly with required number from dataset
    Recall = zeros(Q_num, 11); % initial value, 0.11-0.22-0.33...0.99,1
    Precision = zeros(Q_num, 11); % initial value, 0.11-0.22-0.33...0.99,1
    for i = 1:Q_num
        Recall(i, 1) = 1 / length(ClusterData(ClusterID == QueryID(i)));
        [Query_Indx, Q_distance] = Query_distance(Qdata{i}, ClusterData);
        Precision(i, 1) = 1;
        for j = 2:11 % initial value, 0.11-0.22-0.33...0.99,1
            fprintf('Retrievaling the data....%f%%\n', j / 11 * 100);
            if j == 11
                Recall(i, j) = 1;
            else
                Recall(i, j) = 0.11 * (j - 1);
            end
            Clustered_Indx = 0; %% not important parameter that can be ignore here
            [Retrieved_Data, Retrieved_Indx] = Retrieval_data(Query_Indx, QueryID(i), ...
                                                              Clustered_Indx, ClusterData, ClusterID, Recall(i, j));
            Relevant_Indx = find(ClusterID == QueryID(i));
            Precision(i, j) = length(intersect(Relevant_Indx, Retrieved_Indx)) / length(Retrieved_Indx);
        end
    end
    drawPRC(Recall, Precision);

    %% SVM classifier
    %% construct training and test dataset for SVM Classifier
    %     [traindata,testdata,trainGID,testGID] = construct_svmdata(TRAJDB,TRAJSAMPLES,...
    %                            TRAJDB_DES,TRAJSAMPLES_DES,INTEGRATE_DES,INTEGRATESAMPLES_DES);
    %% hmm classifier
    fprintf(1, 'loading training data...\n');
    load ([ROOT, '.mat']); load ([ROOT, 'samples.mat']);
    [traindata, testdata, trainGID, testGID] = construct_hmmdata(TRAJDB, TRAJSAMPLES, ...
                                                                 TRAJDB_DES, TRAJSAMPLES_DES, INTEGRATE_DES, INTEGRATESAMPLES_DES);
    %% implement recognition using fusion descriptor for two hand simultantaneously
    samples_r = size(INTEGRATE_DES, 2);
    samples_t = size(INTEGRATESAMPLES_DES, 2);
    dtw_distance = zeros(samples_t, samples_r);
    for i = 1:samples_t
        for j = 1:samples_r
            fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n', i, j, samples_r * samples_t, (samples_r * (i - 1) + j) * 100 / (samples_r * samples_t));
            %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i, j), ~, ~] = dtw_adj_orien(TRAJSAMPLES_DES{1, i}, TRAJDB_DES{1, j}, INTEGRATESAMPLES_DES{1, i}, INTEGRATE_DES{1, j}, 1, 100); %#ok<SAGROW>
        end
    end
    dtw_distance = exp(-gamma * dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
    dtw_distance = dtw_distance ./ repmat(sum(dtw_distance, 2), 1, samples_r); %% softmax of dtw distance -- Perry 28/05/2013
    [~, I] = max(dtw_distance, [], 2); % sum up the recognition accurate ratio
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i, j) = length(find(testGID == i & trainGID(I) == j));
        end
    end
    recog_ratio_interg(experiment_num) = trace(confusion_matrix) / sum(confusion_matrix(:));

    recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
    confusion_matrix_interg{1, experiment_num} = confusion_matrix;
    distance_matrix_interg{1, experiment_num} = dtw_distance;
    %% implement recognition using differential invariants
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor(RFHD);
    %     gene_descriptor_mj(joints_no,mj);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_samples(RFHD);
    %     gene_descriptor_samples_mj(joints_no,mj_samples);
    load ([RFHD '_des.mat']);
    load ([RFHD 'samples_des.mat']);
    %     load (['MJ' '_des.mat']);
    %     load (['MJ' 'samples_des.mat']);
    for i = 1:samples_t
        for j = 1:samples_r
            fprintf ('the %d/%d--%d recognition for differential descriptor...%2.2f%%\n', i, j, samples_r * samples_t, (samples_r * (i - 1) + j) * 100 / (samples_r * samples_t));
            %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i, j), ~, ~] = dtw_adj_orien(TRAJSAMPLES_DES{1, i}, TRAJDB_DES{1, j}, INTEGRATESAMPLES_DES{1, i}, INTEGRATE_DES{1, j}, 1, 50);
        end
    end
    dtw_distance = exp(-gamma * dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
    dtw_distance = dtw_distance ./ repmat(sum(dtw_distance, 2), 1, samples_r); %% softmax of dtw distance -- Perry 28/05/2013
    [~, I] = max(dtw_distance, [], 2); % sum up the recognition accurate ratio
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i, j) = length(find(testGID == i & trainGID(I) == j));
        end
    end
    recog_ratio_diff(experiment_num) = trace(confusion_matrix) / sum(confusion_matrix(:));

    recog_ratio_final_diff = mean(recog_ratio_diff) %#ok<NOPTS>
    confusion_matrix_diff{1, experiment_num} = confusion_matrix;
    distance_matrix_diff{1, experiment_num} = dtw_distance;
    %% save and clear variables
    delete *.mat;
    save  RECOGNITION_TALBLE_INTERG distance_matrix_diff distance_matrix_interg;
    save  RECOGNITION_RATIO confusion_matrix_diff confusion_matrix_interg recog_ratio_interg recog_ratio_diff; % recog_ratio_svm;
    clearvars -except BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM CLASS_NUM noise_level;
    load RECOGNITION_RATIO; load RECOGNITION_TALBLE_INTERG;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clearvars;
