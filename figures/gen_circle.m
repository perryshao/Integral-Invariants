function circle = gen_circle(R)
n = 100;
theta = 0;
step = 2 * pi / n;
for i = 1:n

    circle(i, 1) = R * cos(theta);
    circle(i, 2) = R * sin(theta);
    theta = theta + step;

end
