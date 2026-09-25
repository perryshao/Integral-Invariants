function sub_sampling(marker)
%% detect whether there are existing required mat files for C3D data

fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end
%% read required length of joint 3D data with matrix format and filter it
samples = size(TRAJDB, 2);
for i = 1:samples
    length = size(TRAJDB{2, i}, 1);
    length = length - mod(length, 2);
    temp_TRAJDB = [];
    for j = 2:2:length
        temp_TRAJDB(end + 1, :) = TRAJDB{2, i}(j, :);
    end
    TRAJDB{2, i} =  temp_TRAJDB;
end
save(marker, 'TRAJDB');
%% process the samples data
fileprefix = 'samples.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() function');
end
%% read required length of joint 3D data with matrix format and filter it
samples = size(TRAJSAMPLES, 2);
for i = 1:samples
    length = size(TRAJSAMPLES{2, i}, 1);
    length = length - mod(length, 2);
    temp_TRAJSAMPLES = [];
    for j = 2:2:length
        temp_TRAJSAMPLES(end + 1, :) = TRAJSAMPLES{2, i}(j, :);
    end
    TRAJSAMPLES{2, i} =  temp_TRAJSAMPLES;
end
save(matfilename, 'TRAJSAMPLES');
