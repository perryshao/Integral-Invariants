function run_octave_validation(root, work)
% RUN_OCTAVE_VALIDATION Execute original IID functions on generated fixtures.
%   Outputs and rebuilt MEX files stay in the caller's temporary directory.
oldpath = path;
oldpwd = pwd;
cleanup = onCleanup(@() restore_session(oldpath, oldpwd));
cd(work);
sources = {'mbs/src/Determine_segment.cpp', ...
           'mbs/src/tricircumcenter3d.cpp', ...
           'mbs/src/MelkmanConvexHull.cpp', ...
           'matching/src/dtwpath/dtwpath.cpp', ...
           'matching/src/distance_matrix/distance_matrix_norm1.cpp', ...
           'matching/src/distance_matrix/distance_matrix_norm2.cpp', ...
           'matching/src/distance_matrix/distance_matrix_kt.cpp'};
for i = 1:numel(sources)
    [~, name] = fileparts(sources{i});
    mkoctfile('--mex', ['-I' fullfile(fileparts(mfilename('fullpath')), 'octave_include')], fullfile(root, sources{i}), '-o', fullfile(work, name));
end
for folder = {'core', 'preprocess', 'mbs', 'matching', 'baselines', 'validation'}
    addpath(fullfile(root, folder{1}));
end
addpath(work, '-begin');
load(fullfile(work, 'fixtures.mat'));
[clean, indices] = remove_stapoint(repeated);
restored = fillstapoint(clean, indices);
assert(isequal(restored, repeated));
normalized = normalization(curve);
grid_curve = curve_grid(curve, 1000);
mbs = splitting_curve_3D(grid_curve, 8);
segments = mbs.B_E_seg;
aii = integral_invariant_kn(curve, 8, 32);
maii = integral_invariant_mkn(curve, 8, 32);
dii = integral_invariant_dist(curve, 32);
mdii = integral_invariant_dist_mkn(curve, 32);
aii_fixed = integral_invariant(curve, 8, 0.1);
maii_fixed = integral_invariant_ms(curve, 8, 0.1);
mdii_fixed = integral_invariant_dist_ms(curve, 0.1);
frames = Estimate_Frenet(curve, 8);
assert(all(isfinite([aii(:); maii(:); dii(:); mdii(:); frames(:); ...
                     aii_fixed(:); maii_fixed(:); mdii_fixed(:)])));
stat = estimate_integral_dist([0:4; zeros(2, 5)]', 1.1, 3);
assert(abs(stat - 0.5) < 1e-12);
% Repeated rows and the documented difference between DII and MDII lengths.
repeat_dii = integral_invariant_dist(repeated, 32);
repeat_mdii = integral_invariant_dist_mkn(repeated, 32);
assert(size(repeat_dii, 1) == size(curve, 1));
assert(size(repeat_mdii, 1) == size(repeated, 1));
% Actual MEX gateway used by the core with one, two and three outputs.
cc = tricircumcenter3d([0 0 0], [2 0 0], [0 2 0]);
[cc2, xi] = tricircumcenter3d([0 0 0], [2 0 0], [0 2 0]);
[cc3, xi3, eta] = tricircumcenter3d([0 0 0], [2 0 0], [0 2 0]);
assert(isequal(cc, [1 1 0]) && isequal(cc, cc2) && isequal(cc, cc3));
assert(xi == 0.5 && xi3 == 0.5 && eta == 0.5);
try
    cal_descriptors(curve, 7);
    error('test:missingError', 'Removed descriptor flag unexpectedly accepted.');
catch err
    assert(strcmp(err.identifier, 'IID:unsupportedDescriptorFlag'));
end
% Save/load the descriptors before matching to exercise file interchange.
save('-mat7-binary', fullfile(work, 'generated_descriptors.mat'), 'mdii');
loaded = load(fullfile(work, 'generated_descriptors.mat'));
assert(isequal(loaded.mdii, mdii));
queries = {curve, curve2, curve3};
feature_bank = cellfun(@(x) integral_invariant_dist_mkn(x, 32), queries, 'UniformOutput', false);
rotation = [0 -1 0; 1 0 0; 0 0 1];
query_bank = cellfun(@(x) integral_invariant_dist_mkn(3 * x * rotation + repmat([4 2 -3], size(x, 1), 1), 32), queries, 'UniformOutput', false);
dataset_scores = zeros(4, 3, 3);
datasets = {'ASL', 'HDM05', 'MHAD', 'MSRC12'};
for dataset = 1:4
    folder = fullfile(root, 'experiments', datasets{dataset});
    addpath(folder, '-begin');
    clear dtw_adj_matching feature_dist_matching gene_descriptor_integral gene_descriptor_integral_samples;
    assert(strcmp(which('dtw_adj_matching'), fullfile(folder, 'dtw_adj_matching.m')));
    for i = 1:3
        for j = 1:3
            dataset_scores(dataset, i, j) = dtw_adj_matching(query_bank{i}, feature_bank{j}, 100, 6);
        end
    end
    scores = squeeze(dataset_scores(dataset, :, :));
    [~, labels] = min(scores, [], 2);
    assert(isequal(labels, [1; 2; 3]));
    % Real dataset descriptor generators: serialize their expected input cells,
    % invoke both train/test entry points, then compare generated files.
    TRAJDB = {1; curve};
    TRAJSAMPLES = TRAJDB;
    save('-mat7-binary', 'synthetic.mat', 'TRAJDB');
    save('-mat7-binary', 'syntheticsamples.mat', 'TRAJSAMPLES');
    gene_descriptor_integral('synthetic');
    gene_descriptor_integral_samples('synthetic');
    training = load('synthetic_DES.mat');
    testing = load('syntheticsamples_DES.mat');
    train_feature = training.TRAJDB_DES{1};
    test_feature = testing.TRAJSAMPLES_DES{1};
    expected_columns = [4 1 20 10];
    assert(size(train_feature, 2) == expected_columns(dataset));
    assert(all(isfinite(train_feature(:))) && isequal(train_feature, test_feature));
    flags = [3 5 4 4];
    assert(dtw_adj_matching(test_feature, train_feature, 100, flags(dataset)) == 0);
    rmpath(folder);
end
[g, steps] = dtwpath(cost, 100);
trace = traceback_path(steps);
assert(isequal(trace(1, :), [1 1]) && isequal(trace(end, :), size(cost)));
assert(all(all(diff(trace, 1, 1) >= 0)));
save('-mat7-binary', fullfile(work, 'octave_results.mat'), 'aii', 'maii', 'dii', 'mdii', ...
     'aii_fixed', 'maii_fixed', 'mdii_fixed', 'frames', 'normalized', 'grid_curve', ...
     'segments', 'g', 'steps', 'dataset_scores');
fprintf('PASS original MATLAB pipeline, four dataset matchers, MEX outputs, MAT interchange\n');
end

function restore_session(oldpath, oldpwd)
path(oldpath);
cd(oldpwd);
end
