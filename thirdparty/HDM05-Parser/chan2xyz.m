function points = chan2xyz(skel,channels)

temp = skel2xyz(skel,channels(1,:));

points = zeros(size(channels,1),length(temp(:)));
for i=1:size(channels,1),
    points(i,:) = reshape(skel2xyz(skel,channels(i,:))',1,[]);
end