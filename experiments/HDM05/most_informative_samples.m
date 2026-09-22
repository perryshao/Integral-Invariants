function mj = most_informative_samples(joints_no)


fileprefix = 'samples.mat';
matfilename = [joints_no{1,1} fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
samples = size(TRAJSAMPLES,2);
mj = zeros(1,samples);
for i=1:samples
     fprintf ('%d of %d looking for mj joint...\n',i,samples);
     fileprefix = 'samples.mat';
     joint_num = length(joints_no);
     var_xyz = zeros(1,joint_num);
     for j=1:joint_num
         matfilename = [joints_no{1,j} fileprefix];
         if exist(matfilename,'file')
             load(matfilename);
         else
             fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
         end

         marker_xyz = double(TRAJSAMPLES{2,i});
         var_xyz(j) = norm(var(marker_xyz),1);
     end
     [~, index] = max(var_xyz);
     mj(i) = index;
end





