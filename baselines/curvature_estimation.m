function Curvature = curvature_estimation(Curve_xyz, Width)
%% parameter definition
%  Input:
%  Curve_xyz -- input 3d sequence of points
%  Width -- segmentation order authorized for the blurred segments
%  Output:
%  Curvature -- curvature of width at each point of Curve_xyz
%  Initialisation:
%  a=0, b=1, u=0, w=b,
Curve_xyz = remove_stapoint(Curve_xyz);
curve_xyz_int = curve_grid(Curve_xyz, 1000);
Segment_curve = []; %#ok<NASGU>
if size(curve_xyz_int, 2) > 2
    MBS = splitting_curve_3D(curve_xyz_int, Width);
else
    MBS = splitting_curve_2D(curve_xyz_int, Width);
end
n = size(curve_xyz_int, 1);
m = size(MBS.data, 2);
Curvature = zeros(n, 1);
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
for i = 2:(n - 2)
    Curvature(i) = estimate_C(Curve_xyz(i, :), Curve_xyz(L(i), :), Curve_xyz(R(i), :)); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
    %     Segment_curve(end+1:end+3,:) = [Curve_xyz(L(i),:);Curve_xyz(i,:);Curve_xyz(R(i),:)];
end
index = [MBS.B_E_seg(:, 1); MBS.B_E_seg(:, 2)];
index = remove_stapoint(sort(index));
Segment_curve = Curve_xyz(index, :);
figure(1), plot3d(Segment_curve); grid on;
figure(2), plot_MBS; grid on;
