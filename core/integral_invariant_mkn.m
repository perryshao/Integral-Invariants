function integral = integral_invariant_mkn(Curve_xyz, Width, kpoints)
% INTEGRAL_INVARIANT_MKN Compute multiscale area invariants from index neighbourhoods.
%
%   Curve_xyz is an N-by-3 trajectory; Width controls MBS thickness.
%   kpoints controls the index neighbourhood used to derive radii.
%   Output has ten columns, grouped by projection, with five scales each.
%   Static-point rows are restored; boundary entries start at 0.5.

[Curve_xyz, staindex] = remove_stapoint(Curve_xyz); % delete for occlusion fig
curve_xyz_int = curve_grid(Curve_xyz, 1000);
if size(curve_xyz_int, 2) > 2
    MBS = splitting_curve_3D(curve_xyz_int, Width);
else
    MBS = splitting_curve_2D(curve_xyz_int, Width);
end
n = size(curve_xyz_int, 1);
m = size(MBS.data, 2);
multscale = 5;
integral = ones(n, 2 * multscale) * 0.5;
integral_temp = ones(n, 2 * multscale) * 0.5;
% integral1 = zeros(n,2);
%% determine the Right and Left key point through MBS
for i = 1:m
    if i == 1,
        E_num = 1;
    else
        E_num = MBS.B_E_seg(i - 1, 2) + 1;
    end

    for k = E_num:MBS.B_E_seg(i, 2),
        L(k) = MBS.B_E_seg(i, 1);  %#ok<AGROW>
    end

    if i == m,
        B_num = n;
    else
        B_num = MBS.B_E_seg(i + 1, 1) - 1;
    end
    for k = MBS.B_E_seg(i, 1):B_num,
        R(k) = MBS.B_E_seg(i, 2);  %#ok<AGROW>
    end
end

%% construct the Segment curve from MBS
% index= [MBS.B_E_seg(:,1);MBS.B_E_seg(:,2);];
% index = unique(index);
%
% Segment_curve = Curve_xyz(index,:);
% plot3d(Segment_curve);
% Segment_curve = interpolation(Segment_curve,n*2,0);
% Curve_xyz = Segment_curve;
% n = size(Curve_xyz,1);

%% plot the original curve and initial the plot parameters

% set(gcf,'position',[50,50,1152,864]);
% view(-37.5,30);
% plot3(Curve_xyz(:,1),Curve_xyz(:,2),Curve_xyz(:,3),'.k-','LineWidth',2);grid on;hold on;

%% dynamically plot the MBS procedure
% plot_MBS;
%% compute the integral invariants
kns_i = fix(kpoints / 2); % initial value
for i = kns_i + 1:(n - kns_i)
    r = max(norm(Curve_xyz(i, :) - Curve_xyz(i - kns_i, :)), norm(Curve_xyz(i + kns_i, :) - Curve_xyz(i, :)));
    for j = 1:multscale
        integral_temp(i, j * 2 - 1:j * 2) = estimate_integral(Curve_xyz, Curve_xyz(i, :), Curve_xyz(L(i), :), Curve_xyz(R(i), :), r, i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
        kns = fix(kpoints / (2^j));
        r = max(norm(Curve_xyz(i, :) - Curve_xyz(i - kns, :)), norm(Curve_xyz(i + kns, :) - Curve_xyz(i, :)));
    end
end
integral(:, 1:multscale) = integral_temp(:, 1:2:multscale * 2);
integral(:, multscale + 1:end) = integral_temp(:, 2:2:multscale * 2);
integral = fillstapoint(integral, staindex);
