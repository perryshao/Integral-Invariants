function M = Moments(marker_xyz,l,m,n)


samples=size(marker_xyz,1);
Increment = zeros(samples,1);
Increment(2:end) = sum((marker_xyz(2:end,:) - marker_xyz(1:end-1,:)).^2,2);


% handle the translation
Moment_000 = sum((marker_xyz(:,1).^0).*(marker_xyz(:,2).^0).*(marker_xyz(:,3).^0).*Increment);

Moment_100 = sum((marker_xyz(:,1).^1).*(marker_xyz(:,2).^0).*(marker_xyz(:,3).^0).*Increment);
Moment_010 = sum((marker_xyz(:,1).^0).*(marker_xyz(:,2).^1).*(marker_xyz(:,3).^0).*Increment);
Moment_001 = sum((marker_xyz(:,1).^0).*(marker_xyz(:,2).^0).*(marker_xyz(:,3).^1).*Increment);

x_c = Moment_100/Moment_000;y_c = Moment_010/Moment_000;z_c = Moment_001/Moment_000;

Moment = (bsxfun(@minus, marker_xyz(:,1),x_c).^l).*(bsxfun(@minus, marker_xyz(:,2),y_c).^m).*(bsxfun(@minus, marker_xyz(:,3),z_c).^n).*Increment;
M = sum(Moment);
