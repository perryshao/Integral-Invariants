function Plot_Cluster_Traj(trainGID,TRAJDB)
K = length(unique(trainGID));
for i = 1:K
    figure(i),clf,hold on;
    temp_indx = find(trainGID == i);
    cVec = 'bgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmyk';%, cVec = [cVec cVec];
    for j = 1:length(temp_indx)
        plot3d(TRAJDB{temp_indx(j)},cVec(j));
    end
end

