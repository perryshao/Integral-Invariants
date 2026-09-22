function average_dist = estimate_integral_dist(Curve_xyz,kns,pos)
dist = [];k=0;
Curve_length = size(Curve_xyz,1);
%% get the left points in Radius
r = 0;l_k = pos;
n=1;
while (n <= kns+1 && l_k > 1)
    k = k+1;
    dist(k) = norm((Curve_xyz(l_k,:)-Curve_xyz(pos,:)));
    l_k = l_k-n;
    n = n+1;
end
%% get the right points in Radius
r = 0;r_k = pos;
n=1;
while (n <= kns+1 && r_k < Curve_length)
    k = k+1;
    dist(k) = norm((Curve_xyz(r_k,:)-Curve_xyz(pos,:)));
    r_k = r_k+n;
    n = n+1;
end
if isempty(dist)
    average_dist = NaN;
elseif length(dist) == 1
    average_dist = dist;
else
    if ~any(dist)
        average_dist = 0;
    else
        average_dist = mean(dist)/(max(dist)-min(dist));
    end
end
end
