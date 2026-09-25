function MBS = splitting_curve_3D(Curve_xyz, Width)
% SPLITTING_CURVE_3D Decompose a discrete 3-D curve into maximal blurred segments.
%
%   Curve_xyz contains grid coordinates and needs at least two points.
%   Width controls segment thickness. MBS.data holds segment coordinates;
%   MBS.B_E_seg holds their one-based start/end indices. Requires the
%   Determine_segment MEX function for the XY and XZ projections.

k = 1; Sb = Curve_xyz(1, :);
n = size(Curve_xyz, 1);
data = {};
parameter = [0 0 0 0];
B_E_seg = [];
MBS = struct('data', {data}, 'parameter', parameter, 'B_E_seg', B_E_seg);

%% begin main procedure
while k < n,
    k = k + 1; Sb(end + 1, :) = Curve_xyz(k, :);
    %% determinde the OXY and OXZ plane parameters respectively
    [~, eSegment_xy] = Determine_segment(Sb(:, 1:2), Width);
    [~, eSegment_xz] = Determine_segment(Sb(:, 1:2:3), Width);
    if eSegment_xz == 0, eSegment_xz = 1000; end % MAX U point = 1000 in MEX files
    if eSegment_xy == 0, eSegment_xy = 1000; end % MAX U point = 1000 in MEX files
    if min(eSegment_xy, eSegment_xz) < k
        break;
    end
end
bSegment = 1; eSegment = min(eSegment_xy, eSegment_xz);
MBS.data{end + 1} = Curve_xyz(bSegment:eSegment, :);
MBS.B_E_seg(end + 1, :) = [bSegment eSegment];
while k < n

    while k < n, %% perry
        bSegment = bSegment + 1;
        Sb = Curve_xyz(bSegment:k, :);
        %% determinde the OXY and OXZ plane parameters respectively
        [~, eSegment_xy] = Determine_segment(Sb(:, 1:2), Width);
        [~, eSegment_xz] = Determine_segment(Sb(:, 1:2:3), Width);
        if eSegment_xz == 0, eSegment_xz = 1000; end % MAX U point = 1000 in MEX files
        if eSegment_xy == 0, eSegment_xy = 1000; end % MAX U point = 1000 in MEX files
        if min(eSegment_xy, eSegment_xz) == size(Sb, 1)
            break;
        end
    end
    while k < n,
        k = k + 1;
        Sb(end + 1, :) = Curve_xyz(k, :);
        %% determinde the OXY plane parameters
        [~, eSegment_xy] = Determine_segment(Sb(:, 1:2), Width);
        [~, eSegment_xz] = Determine_segment(Sb(:, 1:2:3), Width);
        if eSegment_xz == 0, eSegment_xz = 1000; end % MAX U point = 1000 in MEX files
        if eSegment_xy == 0, eSegment_xy = 1000; end % MAX U point = 1000 in MEX files
        if min(eSegment_xy, eSegment_xz) < size(Sb, 1)
            break;
        end
    end
    eSegment = k - 1;
    MBS.data{end + 1} = Curve_xyz(bSegment:eSegment, :);
    MBS.B_E_seg(end + 1, :) = [bSegment eSegment];
end
