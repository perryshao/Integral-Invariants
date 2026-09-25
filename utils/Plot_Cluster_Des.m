function Plot_Cluster_Des(trainGID, TRAJDB_DES)
K = length(unique(trainGID));
for i = 1:K
    figure(i), clf, hold on;
    %     temp_indx = Clustered_Indx{i};
    temp_indx = find(trainGID == i);
    cVec = 'bgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmyk'; % , cVec = [cVec cVec];
    for j = 1:length(temp_indx)
        %         plot3d(ClusterRawData{temp_indx(j)}(:,1:3),cVec(j));
        plot(TRAJDB_DES{temp_indx(j)}(:, 1), ['-' cVec(j)]);
        %         plot(TRAJDB_DES{temp_indx(j)}(:,3),['-' cVec(j)]);
    end
end
