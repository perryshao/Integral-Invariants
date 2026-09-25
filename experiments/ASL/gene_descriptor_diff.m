function gene_descriptor_diff(marker)
fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end
fileextend = '_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descriptor
samples = size(TRAJDB, 2);
TRAJDB_DES = cell (1, samples);
for i = 1:samples
    marker_xyz = double(TRAJDB{2, i});
    fprintf ('%d of %d differential descriptor...\n', i, samples);
    %% differential invariants   <<< ACTIVE
    %     marker_des = integral_invariant_dist_ms(marker_xyz,0.4);
    marker_des = descriptor_comp(marker_xyz);
    %% raw data
    %     marker_des = marker_xyz;
    %% final descriptor
    TRAJDB_DES{1, i} = marker_des(:, :);
end
save(matfilename, 'TRAJDB_DES');
