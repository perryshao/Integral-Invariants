clear all
%% define the experiment times and class numbers
% noise_level = [0.15 0.1 0.08 0.06 0.04 0.02];
noise_level = 0;
EXPERIMENT_TIMES=length(noise_level);
% EXPERIMENT_TIMES = 5;% repeated times of experiment
CLASS_NUM = 16;% class numbers for classification task
SAMPLES_NUM = 8; % training samples numbers
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'sign_data_bat/';  %LOCATION OF C3D FILES
file_ext = '.sign';
folder_content = dir(BAT_FOLDER);
class_num = size(folder_content,1);
class_num = class_num-2;
class_array = 1:class_num;
K=randperm(class_num);
CLASS_SELECTED = class_array(K(1:CLASS_NUM));
distance_matrix_interg = cell(1,EXPERIMENT_TIMES);
confusion_matrix_interg = cell(1,EXPERIMENT_TIMES);
distance_matrix_diff = cell(1,EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1,EXPERIMENT_TIMES);

%% define the joint name
RWRA = 'SIGN_RWRA';
joints_no = {RWRA};
gamma = 0.5;
%% begin the recognition
for experiment_num=1:EXPERIMENT_TIMES
    %% generate random samples
    random_seed=rand(1,SAMPLES_NUM);
    %% load database
    load_sign_bat(joints_no,random_seed,CLASS_SELECTED,BAT_FOLDER);
    preprocess_bat(joints_no,1);
    add_noise_bat(joints_no,noise_level(experiment_num));

    %% shuffling the whole dataset
    fprintf ('shuffling the dataset...\n');
    shuffle_sort = [ 1 3 5 7 9 ;
                     2 4 6 8 0];
    [subjectID_DB,subjectID_SAMPLES] = shuffle_db(joints_no,shuffle_sort);
    %% pick up the most informative joints
%     mj = most_informative(joints_no);
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor_integral(RWRA);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_integral_samples(RWRA);

%     %% shuffling the whole dataset
%     fprintf ('shuffling the dataset...\n');
%     shuffle_sort = [ 1 3 5;
%                      2 4 0];
%     [subjectID_DB subjectID_SAMPLES] = shuffle_db(markers,shuffle_sort);
%     shuffle_des(STRN,shuffle_sort,subjectID_DB, subjectID_SAMPLES);
    load ([RWRA '_des.mat']);
    load ([RWRA 'samples_des.mat']);
    %% clustering and retrieval test
    fprintf(1,'loading training data...\n');
    load ([RWRA,'.mat']);load ([RWRA,'samples.mat']);
    [ClusterRawData, ClusterData, ClusterID] = ClusterSignData(TRAJDB,TRAJSAMPLES,...
        TRAJDB_DES,TRAJSAMPLES_DES);
    delta = 1;
    [Clustered_Indx, Ctrs,C_distance] = Spec_Clustering(ClusterData,CLASS_NUM,3,delta,C_distance);
    Clustered_accuracy = Get_ClusterAccuracy(Clustered_Indx,ClusterID);
    Plot_Cluster(ClusterRawData,ClusterID,Clustered_Indx);
    Q_num = 5; % the number of query data
    [Qdata, QueryID] = PickupQuery(ClusterData,ClusterID,Q_num); % pick up the query data randomly with required number from dataset
    Recall = zeros(Q_num,11);% initial value, 0.11-0.22-0.33...0.99,1
    Precision = zeros(Q_num,11);% initial value, 0.11-0.22-0.33...0.99,1
    for i = 1:Q_num
        Recall(i,1) = 1/length(ClusterData(ClusterID==QueryID(i)));
        [Query_Indx, Q_distance] = Query_distance(Qdata{i},ClusterData);
        Precision(i,1) = 1;
        for j = 2:11 % initial value, 0.11-0.22-0.33...0.99,1
            fprintf('Retrievaling the data....%f%%\n',j/11*100);
            if j == 11
                Recall(i,j) = 1;
            else
                Recall(i,j) = 0.11*(j-1);
            end
            [Retrieved_Data, Retrieved_Indx] = Retrieval_data(Query_Indx,QueryID(i),Clustered_Indx,ClusterData,ClusterID,Recall(i,j));
            Relevant_indx = find(ClusterID == QueryID(i));
            Precision(i,j) = length(intersect(Relevant_indx,Retrieved_Indx))/length(Retrieved_Indx);
        end
    end
    drawPRC(Recall,Precision);
    %% hmm classifier
     fprintf(1,'loading training data...\n');
     load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
     [traindata, testdata, trainGID,testGID]=construct_hmmdata(TRAJDB,TRAJSAMPLES,...
                              TRAJDB_DES,TRAJSAMPLES_DES,INTEGRATE_DES,INTEGRATESAMPLES_DES);
    %% implement recognition using fusion descriptor for two hand simultantaneously
    samples_r=size(TRAJDB_DES,2);
    samples_t=size(TRAJSAMPLES_DES,2);
    dtw_distance = zeros(samples_t,samples_r);
    for i=1:samples_t
        for j=1:samples_r
            fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
    %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i,j), ~, ~]=dtw_adj_matching(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},50,0); %#ok<SAGROW>
        end
    end
    dtw_distance = exp(-gamma*dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
    dtw_distance = dtw_distance./repmat(sum(dtw_distance,2),1, samples_r);%% softmax of dtw distance -- Perry 28/05/2013
    [~,I] = max(dtw_distance,[],2); % sum up the recognition accurate ratio
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
        end
    end

    recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
    recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
    confusion_matrix_interg{1,experiment_num} = confusion_matrix;
    distance_matrix_interg{1,experiment_num} = dtw_distance;
    %% implement recognition using differential invariants
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor(RWRA);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_samples(RWRA);
    load ([RWRA '_des.mat']);
    load ([RWRA 'samples_des.mat']);
    for i=1:samples_t
        for j=1:samples_r
            fprintf ('the %d/%d--%d recognition for differential descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
    %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i,j), ~, ~]=dtw_adj_matching(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},50,0);
        end
    end
    dtw_distance = exp(-gamma*dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
    dtw_distance = dtw_distance./repmat(sum(dtw_distance,2),1, samples_r);%% softmax of dtw distance -- Perry 28/05/2013
    [~,I]=max(dtw_distance,[],2); % sum up the recognition accurate ratio
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
        end
    end

    recog_ratio_diff(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
    recog_ratio_final_diff = mean(recog_ratio_diff) %#ok<NOPTS>
    confusion_matrix_diff{1,experiment_num} = confusion_matrix;
    distance_matrix_diff{1,experiment_num} = dtw_distance;
    %% save the results
    delete *.mat;
    % save  RECOGNITION_TALBLE_SINGLE dtw_distance;
    save  RECOGNITION_TALBLE_INTERG distance_matrix_diff distance_matrix_interg;
    save  RECOGNITION_RATIO confusion_matrix_diff confusion_matrix_interg recog_ratio_interg recog_ratio_diff;%recog_ratio_svm;
%     save RECOGNITION_RATIO_SINGLE recog_ratio_single
    clearvars -except BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM CLASS_NUM noise_level;
    load RECOGNITION_RATIO; load RECOGNITION_TALBLE_INTERG;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clear all;


