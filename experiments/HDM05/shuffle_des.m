function shuffle_des(marker, shuffle_sort, subjectID_DB, subjectID_SAMPLES)

fileprefix = '_DES.mat';
matfilename_db = [marker fileprefix];
if exist(matfilename_db, 'file')
    load(matfilename_db);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end

fileprefix = 'samples_DES.mat';
matfilename_samples = [marker fileprefix];
if exist(matfilename_samples, 'file')
    load(matfilename_samples);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() function');
end
samples_r = size(TRAJDB_DES, 2);
samples_t = size(TRAJSAMPLES_DES, 2);
tempTRAJDB_DES = cell(1, []);
tempTRAJSAMPLES_DES = cell(1, []);
%% COLLECT TRAIN DESCRIPTOR

for i = 1:samples_r
    is = ismember(shuffle_sort(1:2:5, :), subjectID_DB(i, :));
    if any(all(is, 2))
        tempTRAJDB_DES{1, end + 1} = TRAJDB_DES{1, i};
    end
end

for i = 1:samples_t
    is = ismember(shuffle_sort(1:2:5, :), subjectID_SAMPLES(i, :));
    if any(all(is, 2))
        tempTRAJDB_DES{1, end + 1} = TRAJSAMPLES_DES{1, i};
    end
end

%% COLLECT SAMPLES DESCRIPTOR

for i = 1:samples_r
    is = ismember(shuffle_sort(2:2:5, :), subjectID_DB(i, :));
    if any(all(is, 2))
        tempTRAJSAMPLES_DES{1, end + 1} = TRAJDB_DES{1, i};
    end
end

for i = 1:samples_t
    is = ismember(shuffle_sort(2:2:5, :), subjectID_SAMPLES(i, :));
    if any(all(is, 2))
        tempTRAJSAMPLES_DES{1, end + 1} = TRAJSAMPLES_DES{1, i};
    end
end
%% save as mat files
TRAJDB_DES = tempTRAJDB_DES;
save(matfilename_db, 'TRAJDB_DES');
TRAJSAMPLES_DES = tempTRAJSAMPLES_DES;
save(matfilename_samples, 'TRAJSAMPLES_DES');
