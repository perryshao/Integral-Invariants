function gene_occlusion_samples(marker, occlusion_level)

matfilename = strcat(marker, 'samples.mat');
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() function');
end
%% read joint 3D data with matrix format and get the descriptor
samples = size(TRAJSAMPLES, 2);
for i = 1:samples
    length = size(TRAJSAMPLES{2, i}, 1);
    length_occlusion = ceil(occlusion_level * length);
    begin_length = ceil(rand(1) * (length - length_occlusion));
    if  begin_length > length - length_occlusion + 1
        begin_length = begin_length - 1;
    end
    if  begin_length < 2
        begin_length = 2; % the start point can not be occluded
    end

    TRAJSAMPLES{2, i}(begin_length:begin_length + length_occlusion, :) = NaN;
end
save(matfilename, 'TRAJSAMPLES');
