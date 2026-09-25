function setup_path()
% SETUP_PATH  Add the IID project to the MATLAB path.
%
%   Run this once per MATLAB session from the IID root:
%       >> setup_path
%
%   Adds code folders recursively, excluding reference variants, then puts the
%   MEX binary folders at the front of the path so the compiled
%   Determine_segment / dtwpath / distance_matrix routines are picked up.
%
%   Dataset folders contain same-named functions. Before running an
%   experiment, change to its experiments/<DATASET> directory and use
%   which -all to verify function resolution. See README.md for details.

root = fileparts(mfilename('fullpath'));

folders = {'core', 'mbs', 'matching', 'baselines', 'preprocess', ...
           'figures', 'utils', 'experiments', 'validation', 'thirdparty'};

for k = 1:numel(folders)
    p = fullfile(root, folders{k});
    if exist(p, 'dir')
        addpath(genpath(p));
    else
        warning('setup_path:missing', 'Folder not found, skipped: %s', p);
    end
end

% Put the compiled binaries ahead of anything else on the path.
addpath(fullfile(root, 'mbs', 'bin'), '-begin');
addpath(fullfile(root, 'matching', 'bin'), '-begin');

% The variant forks are kept for reference only (see README).  They shadow
% functions in core/, so make sure they are NOT on the path.
rmpath(genpath(fullfile(root, 'figures', 'variants')));
rmpath(genpath(fullfile(root, 'validation', 'variants')));

fprintf('IID path configured (root: %s)\n', root);

missing = check_mex();
if isempty(missing)
    fprintf('All required mex functions are available for %s.\n', computer('arch'));
else
    fprintf(2, 'Missing mex for %s: %s\n', computer('arch'), strjoin(missing, ', '));
    fprintf(2, 'See the "Building the mex files" section of README.md.\n');
end
end

function missing = check_mex()
% CHECK_MEX  Report which compiled helpers cannot be resolved on this platform.
required = {'Determine_segment', 'tricircumcenter3d', 'dpcore', 'dtwpath'};
missing = {};
for k = 1:numel(required)
    if exist(required{k}, 'file') ~= 3
        missing{end + 1} = required{k}; %#ok<AGROW>
    end
end
end
