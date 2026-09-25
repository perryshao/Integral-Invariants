function gene_descriptor_samples_mj(joint_no, mj)

TRAJSAMPLES_DES = cell (1, []);
fileprefix = 'samples.mat';
matfilename = [joint_no{1, 1} fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end

%% read joint 3D data with matrix format and get the descriptor
samples = size(TRAJSAMPLES, 2);
%     TRAJDB = normalization_basewhole(marker,joints_no);
for i = 1:samples
    matfilename = [joint_no{1, mj(i)} fileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
    end
    marker_xyz = double(TRAJSAMPLES{2, i});
    fprintf ('%d of %d  samples differential descriptor...\n', i, samples);
    marker_des = descriptor_comp(marker_xyz);
    TRAJSAMPLES_DES{1, end + 1} = marker_des;
end
fileextend = 'samples_DES.mat';
matfilename = ['MJ' fileextend];
save(matfilename, 'TRAJSAMPLES_DES');
