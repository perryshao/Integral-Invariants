function d=feature_dist_orien_matrix(t,r,orientation1,orientation2,flag)
%   flag1 -- 0: for tsd database; 1: for hdm05 database
%   flag2 -- 0: for integral invariants 1: for differential invariants
%   weight_h=1;
% weight_o=0.2;weight_rd=0.8;
% m = size(t,1);
% n = size(r,1);
% dim = size(t,2);
% det_k = zeros(m,n);det_t = zeros(m,n);det_orien = zeros(m,n);det_rd = zeros(m,n);
% S_orien = zeros(m,n);S_k = zeros(m,n);S_t = zeros(m,n);S_rd = zeros(m,n);
% for i=1:m
%
% %%   differential invariants computation
%     det_diff = repmat(t(i,:),n,1)-r;
% %     det_k(i,:) = sqrt(sum(det_diff(:,1:dim).^2,2))'; % for norm-2
%     det_k(i,:) = sum(abs(det_diff(:,1:dim/2)),2)'; % for norm-1
%     det_t(i,:) = sum(abs(det_diff(:,dim/2+1:end)),2)'; % for norm-1
% %%  orientation computation (orientation and distance changes)
%     orientation = repmat(orientation1(i,:),n,1)-orientation2;
%
%     % for hdm05 database recognition
%     if flag == 1
%         % orientation parameters
%         orien = [orientation(:,1:8) orientation(:,9:10) orientation(:,12:13)...
%                  orientation(:,15:16) orientation(:,18:19)];
%         % distance parameters
%         rd = [orientation(:,11) orientation(:,14) orientation(:,17) orientation(:,20)];
%             %% limit the value in <pi,-pi> range
%         [k1 k2] = find(orien > pi);
%         orien(k1,k2) = orien(k1,k2)-2*pi;
%         [k1 k2] = find(orien < -pi);
%         orien(k1,k2) = orien(k1,k2)+2*pi;
%
%
%         % for norm-1
%         S_orien(i,:) = sum(abs([repmat([orientation1(i,1:8) ...
%                orientation1(i,9:10) orientation1(i,12:13) orientation1(i,15:16) orientation1(i,18:19)] ...
%                ,n,1) ...
%                orientation2(:,1:8) ...
%                orientation2(:,9:10) orientation2(:,12:13) orientation2(:,15:16) orientation2(:,18:19)]),2);
%
%         S_rd(i,:) = sum(abs([repmat([orientation1(i,11) orientation1(i,14) orientation1(i,17) orientation1(i,20)] ...
%                ,n,1) ...
%                orientation2(:,11) orientation2(:,14) orientation2(:,17) orientation2(:,20)]),2)';
%
% %         S_k(i,:) = sum(abs([repmat(t(i,:),n,1) r]),2)';
%         S_k(i,:) = sum(abs([repmat(t(i,1:dim/2),n,1) r(:,1:dim/2)]),2)';
%         S_t(i,:) = sum(abs([repmat(t(i,dim/2+1:end),n,1) r(:,dim/2+1:end)]),2)';
%     else
%         %% for tsd recognition
%         orien = orientation(:,1:2);
%         rd = orientation(:,3);
%         S_orien = sum([repmat(orientation1(:,1:2),n,1) orientation2(:,1:2)].^2,2)';
%         S_rd = sum([repmat(orientation1(:,3),n,1) orientation2(:,3)].^2,2)';
%     end
%
%     det_orien(i,:) = sum(abs(orien),2)'; % for norm-1
%     det_rd(i,:) = sum(abs(rd),2)';% for norm-1
%
% end
[det_k,det_t,det_orien,det_rd,S_k,S_t,S_orien,S_rd] = distance_matrix(t,r,orientation1,orientation2);

%% compute the global norm for normalization of different components
% S_m=sum(t(:,1:dim).^2,2);
% S_n=sum(r(:,1:dim).^2,2);
%% compute the overall distance
% discard the gloabal parameter in multiple trajectories recognition -- perry 28/02/13
% d=det_k./(sqrt(S_m)*sqrt(S_n'))+weight_o*det_orien./(sqrt(S_orien))+weight_rd*det_rd./(sqrt(S_rd));
% d=det_k+weight_o*det_orien./(sqrt(S_orien))+weight_rd*det_rd;
% d=det_k+weight_o*det_orien./S_orien+weight_rd*det_rd;
% d=det_k.*det_t./(sqrt(S_m)*sqrt(S_n'))+det_orien./S_orien+det_rd; % for norm-2
% d=det_k./S_k+det_orien./S_orien+det_rd./S_rd; % for norm-1

% d=(det_k./S_k).*(det_t./S_t).*(det_orien./S_orien).*(det_rd./S_rd); % for norm-1
% d =0.9*d+0.1*(det_k./S_k).*(det_t./S_t); % ---- interg 0.7871

% factor_kt = mean(mean(det_orien./S_orien))/mean(mean(det_k./S_k));
factor_kt = mean(mean(det_orien./S_orien))/mean(mean((det_k./S_k).*(det_t./S_t)));
factor_rd = mean(mean(det_orien./S_orien))/mean(mean(det_rd./S_rd));
d=factor_kt*(det_k./S_k).*(det_t./S_t)+(det_orien./S_orien)+factor_rd*(det_rd./S_rd); %---diff: 1 interg:0.9935
% d=(det_orien./S_orien)+factor_rd*(det_rd./S_rd); % for Fourier desciptor
d=(det_k./S_k).*(det_t./S_t);% for single root trajectory
%% for  mutilscale distance integral invariants
% factor_kt = mean(mean(det_orien./S_orien))/mean(mean(det_k./S_k));
% factor_rd = mean(mean(det_orien./S_orien))/mean(mean(det_rd./S_rd));
% d=factor_kt*(det_k./S_k)+(det_orien./S_orien)+factor_rd*(det_rd./S_rd); %---diff: 1 interg:0.9935




