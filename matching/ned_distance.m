function d = ned_distance(t,r)
m = size(t,2);
d=0;
for i = 1:m
        d = d + edit_distance_damerau(t(:,i),r(:,i));
end
