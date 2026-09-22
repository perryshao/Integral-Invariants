function gene_shapecontext(marker)
fileprefix = '.mat';
matfilename=[marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend='_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descritor
samples=size(TRAJDB,2);
TRAJDB_DES = cell (1,samples);
for i=1:samples
    marker_xyz = double(TRAJDB{2,i});
    %% initial shape context computation
    marker_xyz = double(marker_xyz);
    mean_dist_global=[]; % use [] to estimate scale from the data
    nbins_theta=12;
    nbins_alpha=12;
    nbins_r=5;
    nsamp1=size(marker_xyz,1);
    ndum1=0;
    eps_dum=0.15;
    r_inner=1/8;
    r_outer=2;
    % outliers on each iteration
    out_vec_1=zeros(1,nsamp1-4); % beging and ending elements are excluded
    % Frenet Frames
    FrenetVector = Estimate_Frenet(marker_xyz,6,5);
    FVector = FrenetVector(3:end-2,:);
    % compute shape contexts for (transformed) model
    fprintf ('%d of %d shape context descriptor...\n',i,samples);
    Bsamp = marker_xyz(3:end-2,:);
    [BH_theta,BH_alpha,mean_dist_1] = sc3d_compute(Bsamp',FVector',mean_dist_global,nbins_theta,nbins_alpha,nbins_r,r_inner,r_outer,out_vec_1);
    TRAJDB_DES{1,i}=cat(2,BH_theta, BH_alpha);
end
save(matfilename, 'TRAJDB_DES');

