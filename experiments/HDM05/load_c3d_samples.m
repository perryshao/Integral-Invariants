function TRAJSAMPLES = load_c3d_samples(marker)
data_folder = 'c3d_samples/';  % LOCATION OF C3D FILES
file_ext = '.c3d';

folder_content = dir ([data_folder, '*', file_ext]);
ndata = size (folder_content, 1);
itf = c3dserver();

if nargin == 1
    filename = marker;
    fileprefix = 'samples.mat';
    matfilename = [marker fileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        TRAJSAMPLES = cell (2, []);
    end
    for k = 1:ndata
        fprintf ('Loading c3d samples data...\n');
        string = [data_folder, folder_content(k, 1).name];
        %%  detect whether there are same files that had been read before
        f = 0;
        col = size(TRAJSAMPLES);
        for i = 1:col(2)
            if strcmp(TRAJSAMPLES{1, i}, string)
                f = 1;
            end
        end
        if f == 1
            continue;
        end
        %% identified the frame length
        fid = fopen(string, 'r', 'n'); % native format (PC-intel)
        if fid == -1,
            h = errordlg(['File: ', FileName, ' could not be opened'], 'application error');
            uiwait(h)
            return
        end
        fseek(fid, 2, 'bof');
        Nmarkers = fread(fid, 1, 'int16');                  % number of markers
        NanalogSamplesPerVideoFrame = fread(fid, 1, 'int16');           % number of analog channels x #analog frames per video frame
        StartFrame = fread(fid, 1, 'int16');                %#of first video frame

        EndFrame = fread(fid, 1, 'int16');                  %#of last video frame
        fclose(fid);

        %%  open C3D files and get structure of c3d files
        openc3d(itf, 1, string);
        frames = nframes(itf);
        start_frame = 1; end_frame = frames;
        c3d_data = get3dtargets(itf);                 % read c3d file data, return a structure matrix
        c3d_data_fields = fieldnames(c3d_data);       % get structure field names,reture a cell matrix

        %% GET required joint 3D data
        field_index = strfind(c3d_data_fields, marker); % return a cell matrix that contarins index of requiried field (joint)
        j = 0;
        num_fields = size(c3d_data_fields);
        while j <= num_fields(1)
            j = j + 1;
            if (~isempty(field_index{j}))
                break;
            end
        end
        TRAJSAMPLES{1, end + 1} = string;
        TRAJSAMPLES{2, end} = c3d_data.(c3d_data_fields{j})(StartFrame:EndFrame, :);
    end
    save(matfilename, 'TRAJSAMPLES');
else
    %% load full data of c3d files
    if exist('trajsamples.mat', 'file')
        load trajdbsamples;
    else
        TRAJSAMPLES = cell (2, []);
    end

    for k = 1:ndata
        fprintf ('Loading c3d samples data...\n');
        string = [data_folder, folder_content(k, 1).name];
        openc3d(itf, 1, string);
        frames = nframes(itf);
        start_frame = 1; end_frame = frames;
        c3d_data = get3dtargets(itf);                 % read c3d file data, return a structure matrix
        TRAJSAMPLES{1, k} = string;
        TRAJSAMPLES{2, k} = c3d_data;
    end
    save trajdbsamples TRAJSAMPLES;
end
closec3d(itf);
fclose('all');
