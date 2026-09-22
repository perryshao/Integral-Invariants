function gene_descriptor(marker)
TRAJDB_DES = cell (1,[]);
fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend = '_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descritor
samples = size(TRAJDB,2);
for i=1:samples
    marker_xyz = double(TRAJDB{2,i});
    %        [marker_xyz,stapoint_index] = remove_stapoint(marker_xyz); % cannot eliminate the static points
    fprintf ('%d of %d differential descriptor...\n',i,samples);
    marker_des = descriptor_comp(marker_xyz);
    TRAJDB_DES{1,end+1} = marker_des;
end
save(matfilename, 'TRAJDB_DES');

