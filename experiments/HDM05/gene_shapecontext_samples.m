function gene_shapecontext_samples(marker)
fileprefix = 'samples.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end
fileextend = 'samples_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descriptor
samples = size(TRAJSAMPLES, 2);
TRAJSAMPLES_DES = cell (1, samples);
for i = 1:samples
    marker_xyz = double(TRAJSAMPLES{2, i});
    %% initial shape context computation
    marker_xyz = double(marker_xyz);
    marker_xyz = remove_stapoint(marker_xyz);
    mean_dist_global = []; % use [] to estimate scale from the data
    nbins_theta = 12;
    nbins_alpha = 12;
    nbins_r = 5;
    nsamp1 = size(marker_xyz, 1);
    ndum1 = 0;
    eps_dum = 0.15;
    r_inner = 1 / 8;
    r_outer = 2;
    % outliers on each iteration
    out_vec_1 = zeros(1, nsamp1);
    % tangent theta
    Tsamp = zeros(1, nsamp1);
    % compute shape contexts for (transformed) model
    fprintf ('%d of %d samples shape context descriptor...\n', i, samples);
    [BH_theta, BH_alpha, mean_dist_1] = sc3d_compute(marker_xyz', Tsamp, mean_dist_global, nbins_theta, nbins_alpha, nbins_r, r_inner, r_outer, out_vec_1);
    TRAJSAMPLES_DES{1, i} = [BH_theta BH_alpha];
end
save(matfilename, 'TRAJSAMPLES_DES');
