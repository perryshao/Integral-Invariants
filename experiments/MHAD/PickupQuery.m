function [Qdata,QueryID] = PickupQuery(ClusterData,ClusterID,Q_num,ClusterRawData)
level = 0.01;
data_num = length(ClusterData);
pick_indx = ceil(rand(1,Q_num)*data_num);
Qdata= ClusterData(pick_indx);
QueryID = ClusterID(pick_indx);

% QRawData = ClusterRawData(pick_indx);
% for i = 1:length(QRawData)
%
%     marker_xyz = QRawData{i};
%
%     mindim = min([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
%         max(marker_xyz(:,2))-min(marker_xyz(:,2))...
%         max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
%     maxdim = max([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
%         max(marker_xyz(:,2))-min(marker_xyz(:,2))...
%         max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
%     noise_f(i) = sqrt(mindim)/sqrt(maxdim);
%     marker_xyz(:,1) = marker_xyz(:,1)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
%     marker_xyz(:,2) = marker_xyz(:,2)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
%     marker_xyz(:,3) = marker_xyz(:,3)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
%
%     fprintf ('%d of %d query integral descriptor...\n',i,length(QRawData));
%     marker_des = integral_invariant_ms(marker_xyz,20,0.3);
%     marker_des = 0.5-marker_des;
%     Qdata{i} = marker_des;
% end
