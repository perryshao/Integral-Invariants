% modified to support running in occlusion situation -- modified by perry
clear all
delete *.mat
%% define the experiment times and class numbers
EXPERIMENT_TIMES = 8;% repeated times of experiment
CLASS_NUM = 4;% class numbers for classification task
SAMPLES_NUM = 8; % training samples numbers
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'bvh_data_bat_MHAD/';  %LOCATION OF C3D FILES
file_ext = '.bvh';
folder_content = dir(BAT_FOLDER);
class_num = size(folder_content,1);
class_num = class_num-2;
class_array = 1:class_num;
K=randperm(class_num);
CLASS_SELECTED = class_array(K(1:CLASS_NUM));
%% show waitbar on screen
% h = waitbar(0,'Recognition is working...');
for experiment_num=1:EXPERIMENT_TIMES
%%  generate random class samples and random training samples
    %%% reset random seeds
    rand('state',sum(100*clock));
    randn('state',sum(100*clock));
    random_seed=rand(1,SAMPLES_NUM);
    %% define the joint name
    RANK = '28' ;RKNE = '26';LANK = '35';LKNE = '33';
    LELB = '19';LWRA = '21';RELB = '12';RWRA = '14';
    STRN = '3';HEAD = '7';
    %% load targets of joints
    joints_no = {RANK,LANK,RKNE,LKNE,STRN,...
               LELB,RELB,LWRA,RWRA,HEAD};
    load_bvh_bat(joints_no,random_seed,CLASS_SELECTED,BAT_FOLDER);
    %% subsample the trajectories

    sub_sampling(RANK);
    sub_sampling(LANK);
    sub_sampling(RKNE);
    sub_sampling(LKNE);
    sub_sampling(STRN);
    sub_sampling(LELB);
    sub_sampling(RELB);
    sub_sampling(LWRA);
    sub_sampling(RWRA);
    % sub_sampling(HEAD);

    sub_sampling(RANK);
    sub_sampling(LANK);
    sub_sampling(RKNE);
    sub_sampling(LKNE);
    sub_sampling(STRN);
    sub_sampling(LELB);
    sub_sampling(RELB);
    sub_sampling(LWRA);
    sub_sampling(RWRA);
    % sub_sampling(HEAD);


    %% preprocess and descriptor computation
    fprintf ('preprocessing the c3d data...%s\n',RANK);
    preprocess(RANK);
    fprintf ('preprocessing the c3d data...%s\n',LANK);
    preprocess(LANK);
    fprintf ('preprocessing the c3d data...%s\n',RKNE);
    preprocess(RKNE);
    fprintf ('preprocessing the c3d data...%s\n',LKNE);
    preprocess(LKNE);
    fprintf ('preprocessing the c3d data...%s\n',STRN);
    preprocess(STRN);
    fprintf ('preprocessing the c3d data...%s\n',LELB);
    preprocess(LELB);
    fprintf ('preprocessing the c3d data...%s\n',RELB);
    preprocess(RELB);
    fprintf ('preprocessing the c3d data...%s\n',LWRA);
    preprocess(LWRA);
    fprintf ('preprocessing the c3d data...%s\n',RWRA);
    preprocess(RWRA);

    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor(STRN);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_samples(STRN);
    load ([STRN '_des.mat']);
    load ([STRN 'samples_des.mat']);
    %%  get relative descriptions of LWRA-LELB for database
    fprintf ('generate the relative descriptor...\n');
    gene_relative_descriptor();
    %% implement recognition using fusion descriptor for two hand simultantaneously
    samples_r=size(INTEGRATE_DES,2);
    samples_t=size(INTEGRATESAMPLES_DES,2);
    for i=1:samples_t
        for j=1:samples_r
    %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i,j), d, g]=dtw_adj_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1,100);
        end
    end
    dtw_distance = exp(-dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
    dtw_distance = dtw_distance./repmat(sum(dtw_distance,2),1, samples_r);%% softmax of dtw distance -- Perry 28/05/2013
    [V I]=max(dtw_distance,[],2); % sum up the recognition accurate ratio
    I'
    recog_ratio=0;
    for i=1:samples_t
        directory_loca=find(TRAJSAMPLES{1,i}=='/');
        samples_directory=TRAJSAMPLES{1,i}(1:directory_loca(2));
        directory_loca=find(TRAJDB{1,I(i)}=='/');
        db_directory=TRAJDB{1,I(i)}(1:directory_loca(2));
       if strcmp(samples_directory,db_directory)
           recog_ratio=recog_ratio+1;
       end
    end

    recog_ratio_interg(experiment_num)=recog_ratio/samples_t;
    recog_ratio_final_interg = mean(recog_ratio_interg)

    %% implement recognizion using one hand differential invariant
    samples_r=size(TRAJDB_DES,2);
    samples_t=size(TRAJSAMPLES_DES,2);
    for i=1:samples_t
        for j=1:samples_r
    %         dtw_distance(i,j)=dtw(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j});
            dtw_distance(i,j)=dtw_adj(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},50);
        end
    end
    [V I]=min(dtw_distance'); % sum up the recognito accurate ratio
    I
    recog_ratio=0;
    for i=1:samples_t
        directory_loca=find(TRAJSAMPLES{1,i}=='/');
        samples_directory=TRAJSAMPLES{1,i}(1:directory_loca(2));
        directory_loca=find(TRAJDB{1,I(i)}=='/');
        db_directory=TRAJDB{1,I(i)}(1:directory_loca(2));
       if strcmp(samples_directory,db_directory)
           recog_ratio=recog_ratio+1;
       end
    end

    recog_ratio_single(experiment_num)=recog_ratio/samples_t;
    recog_ratio_final_single = mean(recog_ratio_single)
    % waitbar(experiment_num/EXPERIMENT_TIMES);
    delete *.mat;
    % save  RECOGNITION_TALBLE_SINGLE dtw_distance;
    save  RECOGNITION_TALBLE_INTERG dtw_distance;
    save  RECOGNITION_RATIO_INTERG recog_ratio_interg;
    save RECOGNITION_RATIO_SINGLE recog_ratio_single
    % save  EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM;
    clearvars -except BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM;
    load RECOGNITION_RATIO_INTERG;
    load RECOGNITION_RATIO_SINGLE;
    % load  EXPERIMENT_PARA;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clear all;

