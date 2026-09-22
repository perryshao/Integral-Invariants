function gene_descriptor_integral_mj(joints_no,mj)

TRAJDB_DES = cell (1,[]);
fileprefix = '.mat';
matfilename = [joints_no{1,1} fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end

%% read joint 3D data with matrix format and get the descritor
samples = size(TRAJDB,2);
%     TRAJDB = normalization_basewhole(marker,joints_no);
for i=1:samples
    matfilename = [joints_no{1,mj(i)} fileprefix];
    if exist(matfilename,'file')
        load(matfilename);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
    end
    marker_xyz = double(TRAJDB{2,i});
    %        [marker_xyz,stapoint_index] = remove_stapoint(marker_xyz); % cannot eliminate the static points
    fprintf ('%d of %d integral descriptor...\n',i,samples);

    marker_des = integral_invariant(marker_xyz,2,0.02);
    TRAJDB_DES{1,end+1} = marker_des;
end
fileextend = '_DES.mat';
matfilename = ['MJ' fileextend];
save(matfilename, 'TRAJDB_DES');

