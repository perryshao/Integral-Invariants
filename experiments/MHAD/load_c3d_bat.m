function load_c3d_bat(markers,random_seed,CLASS_SELECTED,BAT_FOLDER)

file_ext = '.c3d';
fileprefix='.mat';
samplesfileprefix='samples.mat';
db_i = 0; samples_i = 0;
marker_num = size(markers,2);
itf = c3dserver();
%% read random db data from class folder
folder_content = dir(BAT_FOLDER);
class_num=size(folder_content,1);
class_selected_num=size(CLASS_SELECTED,2);
for n=3:class_num  % 2 class recognition, you can define it arbitrarily
    flag_class_num=CLASS_SELECTED-ones(1,class_selected_num)*(n-2);
    if all(flag_class_num)==0
        if folder_content(n,1).isdir==1
            class_folder = folder_content(n,1).name %#ok<NOPRT>
            data_folder=[BAT_FOLDER class_folder '/'];
            class_folder_content = dir ([data_folder,'*',file_ext]);
            ndata = size (class_folder_content,1);

			rand('state',sum(100*clock)); %#ok<RAND>
			randn('state',sum(100*clock)); %#ok<RAND>
			random_db = randperm(ndata,ceil(ndata/2));
%             random_db=round(random_seed*ndata);
%             random_db(find(random_db==0))=1; %#ok<FNDSB>
%             random_db(find(random_db>ndata))=ndata; %#ok<FNDSB>
			random_db_length = size(random_db,2);

            TRAJDB_temp = cell (2,marker_num*random_db_length);
            TRAJSAMPLES_temp = cell (2,marker_num*(ndata-random_db_length));
            for k=1:ndata;

                string= [data_folder,class_folder_content(k,1).name];
                fprintf ('Loading c3d data...');
               %% identified the frame length
                fid=fopen(string,'r','n'); % native format (PC-intel)
                if fid==-1,
                h=errordlg(['File: ',FileName,' could not be opened'],'application error');
                uiwait(h)
                return
                end
                fseek(fid,6,'bof');
    %             Nmarkers=fread(fid,1,'int16');			        %number of markers
    %             NanalogSamplesPerVideoFrame=fread(fid,1,'int16');	%number of analog channels x #analog frames per video frame
                StartFrame=fread(fid,1,'int16');		        % of first video frame
                EndFrame=fread(fid,1,'int16');			        % of last video frame
                fclose(fid);
               %%  open C3D files and get structure of c3d files.
                openc3d(itf,1,string);
                c3d_data=get3dtargets(itf,0,StartFrame,EndFrame);  % read c3d file data, return a structure matrix
                c3d_data_fields=fieldnames(c3d_data);       %get structure field names,reture a cell matrix
                %% detect and distinguish the db and samples data.

                flag_samples_num=unique(random_db)-ones(1,random_db_length)*k;

                if all(flag_samples_num)==0
                    db_i = db_i+1;
                else
                    samples_i = samples_i+1;
                end
                TRAJDB_temp_i = (db_i-1)*marker_num;
                TRAJSAMPLES_temp_i = (samples_i-1)*marker_num;
               %% get required joint 3D data
               for i = 1:marker_num
                   %% identify whether there have a mat file in db
%                     matfilename=[markers{i} fileprefix];
%                     if exist(matfilename,'file')
%                        load(matfilename);
%                     else
%                        TRAJDB = cell (2,[]);
%                     end
%                     %% identify whether there have a mat file in samples
%                     matfilename=[markers{i} samplesfileprefix];
%                     if exist(matfilename,'file')
%                       load(matfilename);
%                     else
%                       TRAJSAMPLES = cell (2,[]);
%                     end
                    field_index=strfind(c3d_data_fields,markers{i}); % return a cell matrix that contarins index of requiried field (joint)
                    j=0;
                    num_fields=size(c3d_data_fields);
                    while j<=num_fields(1)
                        j=j+1;
                        if (~isempty(field_index{j}))
                            break;
                        end
                    end
                    %% detect and distinguish the db and samples data.
                    if all(flag_samples_num)==0
                        TRAJDB_temp{1,TRAJDB_temp_i+i}= string;
                        TRAJDB_temp{2,TRAJDB_temp_i+i} = c3d_data.(c3d_data_fields{j});
                    else
                        TRAJSAMPLES_temp{1,TRAJSAMPLES_temp_i+i}=string;
                        TRAJSAMPLES_temp{2,TRAJSAMPLES_temp_i+i} = c3d_data.(c3d_data_fields{j});
                    end
               end
            end

            for i  = 1:marker_num,

                matfilename=[markers{i} fileprefix];
                if exist(matfilename,'file')
                   load(matfilename);
                else
                   TRAJDB = cell (2,[]);
                end
                %% identify whether there have a mat file in samples
                matfilename=[markers{i} samplesfileprefix];
                if exist(matfilename,'file')
                   load(matfilename);
                else
                   TRAJSAMPLES = cell (2,[]);
                end
                TRAJDB(1:2,end+1:end+db_i) = [TRAJDB_temp(1,i:marker_num:end);TRAJDB_temp(2,i:marker_num:end)];
                TRAJSAMPLES(1:2,end+1:end+samples_i) = [TRAJSAMPLES_temp(1,i:marker_num:end);TRAJSAMPLES_temp(2,i:marker_num:end)];
                save(markers{i},'TRAJDB');
                save(matfilename,'TRAJSAMPLES');
            end

            db_i = 0; samples_i = 0;
        end
    end
%     closec3d(itf);
end
closec3d(itf);
fclose('all');




