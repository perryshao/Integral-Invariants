% Rotation Matrix to Quaternion
% by skaegy (skaegy@gmail.com)

% input
%    rotm, rotation matrix 3*3
% output
%    quat, unit quaternion

function quat=Myrotm2quat(rotm)

% Guo Yao
% qw1=cos(acos((trace(rotm)-1)/2)/2);
% qw=sqrt(1+trace(rotm))/2;
% qx=(rotm(3,2)-rotm(2,3))/(4*qw);
% qy=(rotm(1,3)-rotm(3,1))/(4*qw);
% qz=(rotm(2,1)-rotm(1,2))/(4*qw);

%Perry Shao
% belta = acos((trace(rotm)-1)/2);
% qw=cos(belta/2);
% qx=(rotm(3,2)-rotm(2,3))*sin(belta/2)/(2*sin(belta)+eps);
% qy=(rotm(1,3)-rotm(3,1))*sin(belta/2)/(2*sin(belta)+eps);
% qz=(rotm(2,1)-rotm(1,2))*sin(belta/2)/(2*sin(belta)+eps);

% stable computation

w = trace(rotm);
x = rotm(1,1)-rotm(2,2)-rotm(3,3);
y = rotm(2,2)-rotm(1,1)-rotm(3,3);
z = rotm(3,3)-rotm(1,1)-rotm(2,2);
wxyz = [w,x,y,z];
[maxVal,maxind] = max(wxyz);
biggestVal =sqrt(maxVal+1)/2;
mult = 1/(biggestVal*4);
switch maxind
    case 1
        qw=biggestVal;
		qx=(rotm(2,3)-rotm(3,2))*mult;
		qy=(rotm(3,1)-rotm(1,3))*mult;
		qz=(rotm(1,2)-rotm(2,1))*mult;
    case 2
        qx=biggestVal;
		qw=(rotm(2,3)-rotm(3,2))*mult;
		qy=(rotm(1,2)+rotm(2,1))*mult;
		qz=(rotm(3,1)+rotm(1,3))*mult;
    case 3
        qy=biggestVal;
		qw=(rotm(3,1)-rotm(1,3))*mult;
		qx=(rotm(1,2)+rotm(2,1))*mult;
		qz=(rotm(2,3)+rotm(3,2))*mult;
    case 4
        qz=biggestVal;
		qw=(rotm(1,2)-rotm(2,1))*mult;
		qx=(rotm(3,1)+rotm(1,3))*mult;
		qy=(rotm(2,3)+rotm(3,2))*mult;
end




quat=[qw qx qy qz];
end