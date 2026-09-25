function build_recovered_mex(output_dir)
% BUILD_RECOVERED_MEX Build recovered candidates without replacing shipped MEX files.
root = fileparts(mfilename('fullpath'));
if nargin == 0
    output_dir = fullfile(root, 'build', 'recovered-mex');
end
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
mex('-R2017b', '-outdir', output_dir, fullfile(root, 'mbs/src/MelkmanConvexHull.cpp'));
mex('-R2017b', '-outdir', output_dir, fullfile(root, 'matching/src/distance_matrix/distance_matrix.cpp'));
mex('-R2017b', '-outdir', output_dir, fullfile(root, 'matching/src/distance_matrix/distance_matrix_msrc12.cpp'));
fprintf('Candidates built in %s. Validate them before adding this folder to the path.\n', output_dir);
end
