function TRAJDB = load_c3d(marker)
%% define the location and postfix of c3d files
global DATA_FOLDER;  % LOCATION OF C3D FILES
file_ext = '.c3d';
folder_content = dir ([DATA_FOLDER, '*', file_ext]);
ndata = size (folder_content, 1);
itf = c3dserver();
%% begin reading the c3d data
if nargin == 1
    fileprefix = '.mat';
    matfilename = [marker fileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        TRAJDB = cell (2, []);
    end
    for k = 1:ndata
        %% print the screen hints of loading process
        fprintf ('Loading c3d data...');
        string = [DATA_FOLDER, folder_content(k, 1).name];
        %% detect whether there are same files that had been read before
        f = 0;
        col = size(TRAJDB, 2);
        for i = 1:col
            if strcmp(TRAJDB{1, i}, string)
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
        fseek(fid, 6, 'bof');
        %     Nmarkers=fread(fid,1,'int16');                    %number of markers
        %     NanalogSamplesPerVideoFrame=fread(fid,1,'int16');         %number of analog channels x #analog frames per video frame
        StartFrame = fread(fid, 1, 'int16');                %#of first video frame

        EndFrame = fread(fid, 1, 'int16');                  %#of last video frame
        fclose(fid);
        %%  open C3D files and get structure of c3d files
        openc3d(itf, 1, string);
        %     frames=nframes(itf);
        %     start_frame=1;end_frame=frames;
        c3d_data = get3dtargets(itf);                 % read c3d file data, return a structure matrix
        c3d_data_fields = fieldnames(c3d_data);       % get structure field names,reture a cell matrix
        %% get required joint 3D data
        field_index = strfind(c3d_data_fields, marker); % return a cell matrix that contarins index of requiried field (joint)
        j = 0;
        num_fields = size(c3d_data_fields);
        while j <= num_fields(1)
            j = j + 1;
            if (~isempty(field_index{j}))
                break;
            end
        end
        TRAJDB{1, end + 1} = string;
        TRAJDB{2, end} = c3d_data.(c3d_data_fields{j})(StartFrame:EndFrame, :);
    end
    save(marker, 'TRAJDB');
else
    if exist('trajdb.mat', 'file')
        load trajdb;
    else
        TRAJDB = cell (2, []);
    end
    %% load full data of c3d files
    for k = 1:ndata
        fprintf ('Loading c3d data...');
        string = [DATA_FOLDER, folder_content(k, 1).name];
        openc3d(itf, 1, string);
        c3d_data = get3dtargets(itf);                 % read c3d file data, return a structure matrix
        TRAJDB{1, k} = string;
        TRAJDB{2, k} = c3d_data;
    end
    save trajdb TRAJDB;
end
closec3d(itf);
fclose('all');
clearvars -except DATA_FOLDER;
