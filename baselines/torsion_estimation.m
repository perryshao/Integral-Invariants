function Torsion = torsion_estimation(Curve_xyz, Width)
%% parameter definition
%  Input:
%  Curve_xyz -- input 3d sequence of points
%  Width -- segmentation order authorized for the blurred segments
%  Output:
%  Curvature -- curvature of width at each point of Curve_xyz
%  Initialisation:
%  a=0, b=1, u=0, w=b,
Curve_xyz = remove_stapoint(Curve_xyz);
curve_xyz_int = curve_grid(Curve_xyz, 500);
if size(curve_xyz_int, 2) > 2
    MBS = splitting_curve_3D(curve_xyz_int, Width);
else
    MBS = splitting_curve_2D(curve_xyz_int, Width);
end
n = size(curve_xyz_int, 1);
m = size(MBS.data, 2);
Torsion = zeros(n, 1); %#ok<NASGU>
b = zeros(n, 3);
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
    t1 = Curve_xyz(L(i), :) - Curve_xyz(i, :); t2 = Curve_xyz(R(i), :) - Curve_xyz(i, :);
    t1 = t1 / norm(t1); t2 = t2 / norm(t2);
    b(i, :) = cross(t1, t2);
    if b(i, :) == 0,
        continue;
    else
        b(i, :) = b(i, :) / norm(b(i, :));
    end
end
b = roundn(b, -8);
curve_constructed = construct_curve(b);
% curve_constructed = wav_filter(curve_constructed);
Torsion = Curvature_estimation_sign(curve_constructed, 2);
