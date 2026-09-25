function MBS = splitting_curve_3D_mat(Curve_xyz, Width)
%% parameter definition
%  Input:
%  Curve_xyz -- input 3d sequence of points
%  Width -- segmentation order authorized for the blurred segments
%  Output:
%  MBS -- structure for a list of blurred segments, each of them being defined by its number of points
%  and the characteristics a, b, u, w of a strictly bounding line
%  Initialisation:
%  a=0, b=1, u=0, w=b,
%  MBS = empty
%% Initialisation
k = 1; Sb = Curve_xyz(1, :);
n = size(Curve_xyz, 1);
global a; global b; global u; global w;
global c; global u1; global w1;
a = 0; b = 1; u = 0; w = b;
c = 0; u1 = 0; w1 = b;
isSameOctant =  true;
data = {};
parameter = [0 0 0 0];
B_E_seg = [];
MBS = structure(data, parameter, B_E_seg);
incremental = 0;
%% begin main procedure
while (w - 1) / max(abs(a), abs(b)) <= Width && ...
      (w1 - 1) / max(abs(c), abs(b)) <= Width && k < n,
    k = k + 1; Sb(end + 1, :) = Curve_xyz(k, :);
    %% determinde the OXY and OXZ plane parameters respectively
    isSameOctant = testOctant_3d(Sb);
    if isSameOctant
        Sb_trans = transform_firstOctant(Sb, 1);
        Determine_xy(Sb_trans(:, 1:2), 1);
        Determine_xz(Sb_trans(:, 1:2:3), 1);
        incremental = incremental + 1;
    else
        break;
    end
end
bSegment = 1; eSegment = k - 1;
MBS.data{end + 1} = Curve_xyz(bSegment:eSegment, :);
MBS.B_E_seg(end + 1, :) = [bSegment eSegment];
incremental = 0; %#ok<NASGU>
while k < n

    while ((w - 1) / max(abs(a), abs(b)) > Width) || ((w1 - 1) / max(abs(c), abs(b)) > Width) ...
           || (~isSameOctant) ...
           || isnan((w - 1) / max(abs(a), abs(b))) || isnan((w1 - 1) / max(abs(c), abs(b))) %% perry
        bSegment = bSegment + 1;
        Sb = Curve_xyz(bSegment:k, :);
        %% determinde the OXY and OXZ plane parameters respectively
        isSameOctant = testOctant_3d(Sb);
        if isSameOctant,
            Sb_trans = transform_firstOctant(Sb, 1);
            Determine_xy(Sb_trans(:, 1:2), 1);
            Determine_xz(Sb_trans(:, 1:2:3), 1);
        else
            continue;
        end
    end
    incremental = 0;
    while ((w - 1) / max(abs(a), abs(b)) <= Width) && ...
           ((w1 - 1) / max(abs(c), abs(b)) <= Width) && k < n,
        k = k + 1;
        Sb(end + 1, :) = Curve_xyz(k, :);
        %% determinde the OXY plane parameters
        isSameOctant = testOctant_3d(Sb);
        if isSameOctant,
            Sb_trans = transform_firstOctant(Sb, 1);
            Determine_xy(Sb_trans(:, 1:2), 1);
            Determine_xz(Sb_trans(:, 1:2:3), 1);
            incremental = incremental + 1;
        else
            break;
        end
    end
    eSegment = k - 1;
    MBS.data{end + 1} = Curve_xyz(bSegment:eSegment, :);
    MBS.B_E_seg(end + 1, :) = [bSegment eSegment];
end
