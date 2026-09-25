function area = estimate_integral_interp(Curve_xyz, Ck, Cl, Cr, Radius, pos)
% ESTIMATE_INTEGRAL_INTERP Estimate projected area invariants using interpolated samples.
%
%   Curve_xyz contains trajectory coordinates; Ck, Cl and Cr define the
%   local frame. Radius and the one-based index pos define the evaluation
%   neighbourhood. This legacy interpolation variant requires
%   tricircumcenter3d; its sampling constants are retained unchanged.

area = 0; %#ok<NASGU>
T1 = Ck - Cl; T2 = Cr - Ck;
T1 = T1 / norm(T1);
T2 = T2 / norm(T2);

% B = cross(T1,T2); B= B/norm(B);
% T = (T1+T2)/norm(T1+T2);% modified by perry according to reviews of PR
% N = cross(B,T);

Cc = tricircumcenter3d(Cl, Ck, Cr) + Cl; % get the circumcenter
N = (Cc - Ck) / norm(Cc - Ck);
B = cross(T1, T2); B = B / norm(B);
T = cross(N, B);

D = -(B * Ck');

grids = 500;

%% get the projection on osculating plane
t_dnom = B * B';
t_nom = Curve_xyz * B' + D;
t = t_nom / t_dnom;
Po = Curve_xyz - t * B;
% setzero_flag = 0;
%% tune the Radius when there are double features
% r_k = pos;r_r = 0;Po_length = size(Po,1);flag=0;
% while (r_r <= Radius && r_k < Po_length)
%     if (Po(r_k+1,:)-Po(r_k,:))*T'< 0
%         flag = flag +1;
%         if flag > 2
%             Radius = norm(Po(r_k+1,:)-Po(pos,:));
%             break;
%         end
%     end
%     r_k = r_k+1;
%     r_r = norm(Po(r_k,:)-Po(pos,:));
% end
%% get the area for osculating plane projection
m = size(Po, 1);
Po_vector = (Po - repmat(Po(pos, :), m, 1));
Po_vector_norm = sqrt(sum(Po_vector.^2, 2));
indx = (Po_vector_norm < Radius);
indx_segment = find(indx == 1);
seg_indx = [];
for i = 2:length(indx_segment)
    if indx_segment(i) - indx_segment(i - 1) ~= 1;
        seg_indx(end + 1) = i;
    end
end
if ~isempty(seg_indx)
    pos_indx = find(indx_segment == pos);
    begin_indx = seg_indx(seg_indx < pos_indx);
    end_indx = seg_indx(seg_indx > pos_indx);
    if isempty(begin_indx) && isempty(end_indx)
        indx_segment = indx_segment(pos_indx);
    elseif ~isempty(begin_indx) && ~isempty(end_indx)
        indx_segment = indx_segment(begin_indx(end):end_indx(1) - 1);
    end
    if isempty(begin_indx) && ~isempty(end_indx)
        indx_segment = indx_segment(1:end_indx(1) - 1);
    elseif ~isempty(begin_indx) && isempty(end_indx)
        indx_segment = indx_segment(begin_indx(end):end);
    end

    indx = zeros(m, 1); indx(indx_segment) = 1;
end

% set to zero when the kernel reach the bound
% if indx(1) = 1 || indx(end) = 1
%     setzero_flag = 1;
% end

indx = indx([2:end  end]) | indx([1 1:end - 1]) | indx;
Po_vector = Po_vector(indx, :);
Po_vector = interpolation(Po_vector, grids, 0);
Po_vector_norm = sqrt(sum(Po_vector.^2, 2));
Po_vector((Po_vector_norm > Radius), :) = [];
n = size(Po_vector, 1);
height_u = sqrt(abs(repmat(Radius^2, n, 1) - (Po_vector * T').^2));
height_b = Po_vector * N';
height = height_u - height_b;

% perry added on 1/12/2014
increment = Po_vector(2:end, :) - Po_vector(1:end - 1, :);
increment_norm = sqrt(sum(increment.^2, 2));
costheta = (increment * T') ./ (increment_norm * norm(T));
delta_Po = sqrt(sum((Po_vector(2:end, :) - Po_vector(1:end - 1, :)).^2, 2));
delta_Po = delta_Po .* abs(costheta);
costheta = [0; costheta];
height(costheta < 0) = height(costheta < 0) * -1;

% perry modified on 09/12/2014
delta_Po = cumsum(delta_Po);
% perry added on 15/12/2014
if length(delta_Po) == 2
    delta_Po = [0; delta_Po];
    height = [0; height];
end

area_o = trapz(delta_Po(1:end - 1), height(2:end - 1));
area_o = area_o / (pi * Radius^2);

% set to zero when the kernel reach the bound
% if setzero_flag==1
%     area_o=0;
% end

if area_o > 0.5
    area_o = 1 - area_o;
end

%% get the area for rectifying plane projection

D = -(N * Ck');
t_dnom = N * N';
t_nom = Curve_xyz * N' + D;
t = t_nom / t_dnom;
Pr = Curve_xyz - t * N;
% setzero_flag = 0;
%% tune the Radius dynamically
% r_k = pos;r_r = 0;Pr_length = size(Pr,1);flag=0;
% while (r_r <= Radius && r_k < Pr_length)
%     if (Pr(r_k+1,:)-Pr(r_k,:))*T'< 0
%         flag = flag +1;
%         if flag > 2
%             Radius = norm(Pr(r_k+1,:)-Pr(pos,:));
%             break;
%         end
%     end
%     r_k = r_k+1;
%     r_r = norm(Pr(r_k,:)-Pr(pos,:));
% end
%% new method of approximation area - retifying plane projection
m = size(Pr, 1);
Pr_vector = (Pr - repmat(Pr(pos, :), m, 1));
Pr_vector_norm = sqrt(sum(Pr_vector.^2, 2));
indx = (Pr_vector_norm < Radius);
indx_segment = find(indx == 1);
seg_indx = [];
for i = 2:length(indx_segment)
    if indx_segment(i) - indx_segment(i - 1) ~= 1;
        seg_indx(end + 1) = i;
    end
end
if ~isempty(seg_indx)
    pos_indx = find(indx_segment == pos);
    begin_indx = seg_indx(seg_indx < pos_indx);
    end_indx = seg_indx(seg_indx > pos_indx);
    if isempty(begin_indx) && isempty(end_indx)
        indx_segment = indx_segment(pos_indx);
    elseif ~isempty(begin_indx) && ~isempty(end_indx)
        indx_segment = indx_segment(begin_indx(end):end_indx(1) - 1);
    end
    if isempty(begin_indx) && ~isempty(end_indx)
        indx_segment = indx_segment(1:end_indx(1) - 1);
    elseif ~isempty(begin_indx) && isempty(end_indx)
        indx_segment = indx_segment(begin_indx(end):end);
    end

    indx = zeros(m, 1); indx(indx_segment) = 1;
end

% set to zero when the kernel reach the bound
% if indx(1) = 1 || indx(end) = 1
%     setzero_flag = 1;
% end

indx = indx([2:end  end]) | indx([1 1:end - 1]) | indx;
Pr_vector = Pr_vector(indx, :);
Pr_vector = interpolation(Pr_vector, grids, 0);
Pr_vector_norm = sqrt(sum(Pr_vector.^2, 2));
Pr_vector((Pr_vector_norm > Radius), :) = [];
n = size(Pr_vector, 1);
height_u = sqrt(abs(repmat(Radius^2, n, 1) - (Pr_vector * T').^2));
height_b = Pr_vector * B';
height = height_u - height_b;

% perry added on 1/12/2014
increment = Pr_vector(2:end, :) - Pr_vector(1:end - 1, :);
increment_norm = sqrt(sum(increment.^2, 2));
costheta = (increment * T') ./ (increment_norm * norm(T));

delta_Pr = sqrt(sum((Pr_vector(2:end, :) - Pr_vector(1:end - 1, :)).^2, 2));
delta_Pr = delta_Pr .* abs(costheta);
costheta = [0; costheta];
height(costheta < 0) = height(costheta < 0) * -1;

% perry modified on 09/12/2014
delta_Pr = cumsum(delta_Pr);
% perry added on 15/12/2014
if length(delta_Pr) == 2
    delta_Pr = [0; delta_Pr];
    height = [0; height];
end
area_r = trapz(delta_Pr(1:end - 1), height(2:end - 1));
area_r = area_r / (pi * Radius^2);

% set to zero when the kernel reach the bound
% if setzero_flag==1
%     area_r=0;
% end

% if ~isempty(P_r) && (P_r(end,:) - Pr(pos,:))*T' < 0
%     area_r = 0.5-area_r;
% end

area = [area_o area_r];

%% get the area for normal plane projection
% D = -(T*Ck');
% t_dnom = T*T';
% t_nom = Curve_xyz*T'+D;
% t = t_nom/t_dnom;
% Pn = Curve_xyz-t*T;
%
% % setzero_flag=0;
% %% tune the Radius dynamically
% % r_k = pos;r_r = 0;Pn_length = size(Pn,1);flag=0;
% % while (r_r <= 1 && r_k < Pn_length)
% %     if (Pn(r_k+1,:)-Pn(r_k,:))*B'< 0
% %         flag = flag +1;
% %         if flag > 1
% %             Radius = norm(Pn(r_k+1,:)-Pn(pos,:));
% %             break;
% %         end
% %     end
% %     r_k = r_k+1;
% %     r_r = norm(Pn(r_k,:)-Pn(pos,:));
% % end
%
% %% new method of approximation area - normal plane
% m = size(Pr,1);
% Pn_vector = (Pn - repmat(Pn(pos,:),m,1));
% Pn_vector_norm = sqrt(sum(Pn_vector.^2,2));
% indx = (Pn_vector_norm < Radius);
% indx_segment = find(indx==1);
% seg_indx = [];
% for i = 2:length(indx_segment)
%     if indx_segment(i) - indx_segment(i-1) ~= 1;
%         seg_indx(end+1) = i;
%     end
% end
% if ~isempty(seg_indx)
%     pos_indx = find(indx_segment == pos);
%     begin_indx = seg_indx(seg_indx<pos_indx);
%     end_indx = seg_indx(seg_indx>pos_indx);
%     if isempty(begin_indx) && isempty(end_indx)
%         indx_segment = indx_segment(pos_indx);
%     elseif ~isempty(begin_indx) && ~isempty(end_indx)
%         indx_segment = indx_segment(begin_indx(end):end_indx(1)-1);
%     end
%     if isempty(begin_indx) && ~isempty(end_indx)
%         indx_segment = indx_segment(1:end_indx(1)-1);
%     elseif ~isempty(begin_indx) && isempty(end_indx)
%         indx_segment = indx_segment(begin_indx(end):end);
%     end
%
%     indx = zeros(m,1);indx(indx_segment)=1;
% end
%
% % set to zero when the kernel reach the bound
% % if indx(1) = 1 || indx(end) = 1
% %     setzero_flag = 1;
% % end
%
% indx =indx( [ 2:end  end] ) | indx( [1 1:end-1 ]);
% Pn_vector = Pn_vector(indx,:);
% Pn_vector = interpolation(Pn_vector,grids,0);
% Pn_vector_norm = sqrt(sum(Pn_vector.^2,2));
% Pn_vector((Pn_vector_norm > Radius),:)=[];
% n = size(Pn_vector,1);
% height_u = sqrt(abs(repmat(Radius^2,n,1) - (Pn_vector*B').^2));
% height_b = Pn_vector*N';
% height = height_u-height_b;
%
% % perry added on 1/12/2014
% increment = Pn_vector(2:end,:)-Pn_vector(1:end-1,:);
% increment_norm = sqrt(sum(increment.^2,2));
% costheta = (increment*B')./(increment_norm*norm(B));
%
% delta_Pn = sqrt(sum((Pn_vector(2:end,:)-Pn_vector(1:end-1,:)).^2,2));
% delta_Pn = delta_Pn.*abs(costheta);
% costheta = [0;costheta];
% height(costheta < 0) = height(costheta < 0)*-1;
%
% % perry modified on 09/12/2014
% delta_Pn = cumsum(delta_Pn);
% area_n = trapz(delta_Pn(1:end-1),height(2:end-1));
% area_n = area_n/(pi*Radius^2);
%
% %
% % if setzero_flag == 1
% %     area_n=0.5;
% % end
% %
% %
% area = [area_o area_n];
