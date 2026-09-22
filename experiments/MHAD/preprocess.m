function preprocess(marker,downsamples)
%% detect whether there are existing required mat files for C3D data
fileprefix='.mat';
matfilename=[marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
%% read required length of joint 3D data with matrix format and filter it
samples=size(TRAJDB,2);
for i=1:samples
    % segmentation of NaN occlusion and filter them seperately.
    marker_xyz=TRAJDB{2,i};
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.1*eye(ss);
    R = 1*eye(os);

    %% wave filter
    initx = [marker_xyz(1,1) marker_xyz(1,2) marker_xyz(1,3) 0.1 0.1 0.1]';
    initV = 1*eye(ss);
    [marker_smooth, ~,~,loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    loglik;
    TRAJDB{2,i} = marker_smooth(1:3,:)';
    if downsamples  % 480HZ->120HZ
        length = size(TRAJDB{2,i},1);
        length = length-mod(length,4);
        temp_TRAJDB = [];
        for j=1:4:length
            temp_TRAJDB(end+1,:) = TRAJDB{2,i}(j,:);
        end
        TRAJDB{2,i} =  temp_TRAJDB;
    end
end
save(marker,'TRAJDB');
%% process the samples data
fileprefix='samples.mat';
matfilename=[marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() funcition');
end
%% read required length of joint 3D data with matrix format and filter it
samples=size(TRAJSAMPLES,2);
for i=1:samples
    marker_xyz = TRAJSAMPLES{2,i};
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.1*eye(ss);
    R = 1*eye(os);
    %% kalman filter
    initx = [marker_xyz(1,1) marker_xyz(1,2) marker_xyz(1,3) 0.1 0.1 0.1]';
    initV = 1*eye(ss);
    [marker_smooth, ~,~,loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    loglik;

    TRAJSAMPLES{2,i}= marker_smooth(1:3,:)';
    if downsamples  % 480HZ->120HZ
        length = size(TRAJSAMPLES{2,i},1);
        length = length-mod(length,4);
        temp_TRAJSAMPLES = [];
        for j=1:4:length
            temp_TRAJSAMPLES(end+1,:) = TRAJSAMPLES{2,i}(j,:);
        end
        TRAJSAMPLES{2,i} =  temp_TRAJSAMPLES;
    end
end
save(matfilename,'TRAJSAMPLES');
