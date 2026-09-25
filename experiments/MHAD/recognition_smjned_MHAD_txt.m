% modified to support running in occlusion situation -- modified by perry
clearvars;
delete *.mat
%% define the experiment times and class numbers
EXPERIMENT_TIMES = 1; % repeated times of experiment
CLASS_NUM = 11; % class numbers for classification task
SAMPLES_NUM = 30; % training samples numbers
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'split_txt_data/';  % LOCATION OF C3D FILES
file_ext = '.txt';
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
%% show waitbar on screen
% h = waitbar(0,'Recognition is working...');
m_num = 6; fixed_window = 5; % 6 joints and 0.040*120fps=4.8

for experiment_num = 1:EXPERIMENT_TIMES
    %%  generate random class samples and random training samples
    %%% reset random seeds
    rand('state', sum(100 * clock));
    randn('state', sum(100 * clock));
    random_seed = rand(1, SAMPLES_NUM);
    gamma = 0.5;
    %% define the joint name
    RANK = '26'; RKNE = '24'; LANK = '33'; LKNE = '31';
    LELB = '18'; LWRA = '20'; RELB = '11'; RWRA = '13';
    STRN = '2'; HEAD = '6';
    %% load targets of joints
    joints_no = {RANK, LANK, RKNE, LKNE, ...
                 LELB, RELB, LWRA, RWRA, HEAD};
    %     load_txt_bat(joints_no,random_seed,CLASS_SELECTED,BAT_FOLDER);
    %% preprocess and descriptor computation
    %     fprintf ('preprocessing the c3d data...%s\n',RANK);
    %     preprocess(RANK);
    %     fprintf ('preprocessing the c3d data...%s\n',LANK);
    %     preprocess(LANK);
    %     fprintf ('preprocessing the c3d data...%s\n',RKNE);
    %     preprocess(RKNE);
    %     fprintf ('preprocessing the c3d data...%s\n',LKNE);
    %     preprocess(LKNE);
    % %     fprintf ('preprocessing the c3d data...%s\n',STRN);
    % %     preprocess(STRN);
    %     fprintf ('preprocessing the c3d data...%s\n',LELB);
    %     preprocess(LELB);
    %     fprintf ('preprocessing the c3d data...%s\n',RELB);
    %     preprocess(RELB);
    %     fprintf ('preprocessing the c3d data...%s\n',LWRA);
    %     preprocess(LWRA);
    %     fprintf ('preprocessing the c3d data...%s\n',RWRA);
    %     preprocess(RWRA);
    %     fprintf ('preprocessing the c3d data...%s\n',HEAD);
    %     preprocess(HEAD);
    %
    %     % gene_occlusion_samples(RANK,0.2);
    %     % gene_occlusion_samples('RWRA',0.2);
    %     % gene_occlusion_samples(RWRA);
    %
    %     fprintf ('subsampling the c3d data...%s\n',RANK);
    %     sub_sampling(RANK);
    %     sub_sampling(RANK);
    %     fprintf ('subsampling the c3d data...%s\n',LANK);
    %     sub_sampling(LANK);
    %     sub_sampling(LANK);
    %     fprintf ('subsampling the c3d data...%s\n',RKNE);
    %     sub_sampling(RKNE);
    %     sub_sampling(RKNE);
    %     fprintf ('subsampling the c3d data...%s\n',LKNE);
    %     sub_sampling(LKNE);
    %     sub_sampling(LKNE);
    % %     fprintf ('subsampling the c3d data...%s\n',STRN);
    % %     sub_sampling(STRN);
    % %     sub_sampling(STRN);
    %     fprintf ('subsampling the c3d data...%s\n',LELB);
    %     sub_sampling(LELB);
    %     sub_sampling(LELB);
    %     fprintf ('subsampling the c3d data...%s\n',RELB);
    %     sub_sampling(RELB);
    %     sub_sampling(RELB);
    %     fprintf ('subsampling the c3d data...%s\n',LWRA);
    %     sub_sampling(LWRA);
    %     sub_sampling(LWRA);
    %     fprintf ('subsampling the c3d data...%s\n',RWRA);
    %     sub_sampling(RWRA);
    %     sub_sampling(RWRA);
    %     fprintf ('subsampling the c3d data...%s\n',HEAD);
    %     sub_sampling(HEAD);
    %     sub_sampling(HEAD);

    %% loading the original data
    fprintf ('copying original data...\n');
    copyfile('mat/*.*', '../MHADEvaluatingCode/', 'f');
    %% shuffling the whole dataset
    fprintf ('shuffling the dataset...\n');
    shuffle_sort = [1 3 5 7 9 11;
                    2 4 6 8 10 12];
    [subjectID_DB, subjectID_SAMPLES] = shuffle_db(joints_no, shuffle_sort);
    %% pick up the most informative joints
    %     mj = most_informative(joints_no);
    fprintf ('get the database descriptor for root trajectory...\n');
    mj = smij_feature(joints_no, m_num, fixed_window);
    fprintf ('get the samples descriptor for root trajectory...\n');
    mj_samples = smij_feature_samples(joints_no, m_num, fixed_window);
    %% construct training and test dataset for SVM Classifier
    fprintf(1, 'loading training data...\n');
    load ([HEAD '.mat']);
    load ([HEAD 'samples.mat']);
    [trainGID, testGID] = construct_ID(TRAJDB, TRAJSAMPLES);
    %% svm train
    %     fprintf(1,'training SVM models...\n');
    %     [net K1] = train_libsvm(traindata,trainGID);
    %     [accuracy confusion_matrix K2] = test_libsvm(testdata,traindata,testGID,net);
    %     recog_ratio_svm(experiment_num) = accuracy(1)/100; %#ok<SAGROW>
    %     recog_ratio_final_svm = mean(recog_ratio_svm) %#ok<NOPTS>
    %     fprintf(1,'training SVM models...\n');
    %     net = train_dagsvm(traindata,trainGID);
    %     fprintf(1,'testing SVM models...\n');
    %     [output confusion_matrix] = test_dagsvm(testdata,testGID,net);
    %     recog_ratio_svm(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:)); %#ok<SAGROW>
    %     recog_ratio_final_svm = mean(recog_ratio_svm) %#ok<NOPTS>

    %% implement recognition using fusion descriptor for two hand simultantaneously
    samples_r = size(mj, 1);
    samples_t = size(mj_samples, 1);
    dtw_distance = zeros(samples_t, samples_r);
    for i = 1:samples_t
        for j = 1:samples_r
            fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n', i, j, samples_r * samples_t, (samples_r * (i - 1) + j) * 100 / (samples_r * samples_t));
            %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            dtw_distance(i, j) = ned_distance(mj_samples{i}, mj{j});
        end
    end
    dtw_distance = exp(-dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
    dtw_distance = dtw_distance ./ repmat(sum(dtw_distance, 2), 1, samples_r); %% softmax of dtw distance -- Perry 28/05/2013
    [V I] = max(dtw_distance, [], 2); % sum up the recognition accurate ratio
    I'
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i, j) = length(find(testGID == i & trainGID(I) == j));
        end
    end
    recog_ratio_smij(experiment_num) = trace(confusion_matrix) / sum(confusion_matrix(:));

    recog_ratio_final_smij = mean(recog_ratio_smij) %#ok<NOPTS>
    confusion_matrix_smij{1, experiment_num} = confusion_matrix;
    distance_matrix_smij{1, experiment_num} = dtw_distance;
    %% save and clear variables
    delete *.mat;

    save  RECOGNITION_TALBLE_SMIJ  distance_matrix_smij;
    save  RECOGNITION_RATIO  confusion_matrix_smij recog_ratio_smij % recog_ratio_svm;
    clearvars -except BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM CLASS_NUM;
    load RECOGNITION_RATIO; load RECOGNITION_TALBLE_SMIJ;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clearvars;
