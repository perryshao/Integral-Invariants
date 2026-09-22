function [Indx, dtw_distance] = Query_distance(Qdata,Clusterdata)
num=length(Clusterdata);
dtw_distance = zeros(1,num);
for i=1:num
    fprintf ('dtw computing %d-%d\n',1,i);
%     [dtw_distance(1,i), ~, ~] = dtw_adj_matching(Qdata(:,1:2),Clusterdata{i}(:,1:2),100,0);
    [dtw_distance(1,i), ~, ~] = dtw_adj_orien(Qdata(:,1:20),Clusterdata{i}(:,1:20),...
                                            Qdata(:,21:end),Clusterdata{i}(:,21:end),1,100);
end
[~,Indx] = sort(dtw_distance,2);