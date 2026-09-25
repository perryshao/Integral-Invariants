n = size(MBS.data, 2);
m = size(MBS.data{1, 1}, 2);
dirname = 'moviepic\';
% set(gcf,'position',[50,50,1600,1200]);
figure(1);

for i = 1:n
    X = [MBS.data{1, i}(1, 1); MBS.data{1, i}(end, 1)];
    Y = [MBS.data{1, i}(1, 2); MBS.data{1, i}(end, 2)];
    %         axis equal;
    pause(0.1)
    plot(MBS.data{1, i}(:, 1), MBS.data{1, i}(:, 2), ...
         '.k', 'MarkerSize', 20); hold on; grid on;
    title('Dynamically estimation of Maximal Blurred Segment')
    xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold');
    %     saveas(gcf,strcat(dirname,num2str(i+10),'_1'),'tif')
    set(gca, 'linewidth', 1.5);
    legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
    print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_2'));

    %         axis equal;
    plot(X, Y, 'pr', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); hold on; grid on;
    plot(X, Y, '-b', 'MarkerSize', 10); hold on; grid on;
    xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold');
    %     saveas(gcf,strcat(dirname,num2str(i+10),'_2'),'tif')
    set(gca, 'linewidth', 1.5);
    legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
    print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_2'));
end
axis equal;
print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10 + 1), '_1'));
close(gcf);
im2movie('plot_MBS_2d_xy', dirname);
delete(strcat(dirname, '*.*'));
figure(2);
xlabel('X'); ylabel('Z')
for i = 1:n
    X = [MBS.data{1, i}(1, 1); MBS.data{1, i}(end, 1)];
    Z = [MBS.data{1, i}(1, 3); MBS.data{1, i}(end, 3)];
    %         axis equal;
    pause(0.1)
    plot(MBS.data{1, i}(:, 1), MBS.data{1, i}(:, 3), ...
         '.k', 'MarkerSize', 20); hold on; grid on;
    title('Dynamically estimation of Maximal Blurred Segment')
    xlabel('X', 'FontWeight', 'bold'); ylabel('Z', 'FontWeight', 'bold');
    %     saveas(gcf,strcat(dirname,num2str(i+10),'_1'),'png')
    set(gca, 'linewidth', 1.5);
    legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
    print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_1'))
    %         axis equal;
    plot(X, Z, 'pk', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); hold on; grid on;
    plot(X, Z, '-b', 'MarkerSize', 10); hold on; grid on;
    xlabel('X', 'FontWeight', 'bold'); ylabel('Z', 'FontWeight', 'bold');
    %     saveas(gcf,strcat(dirname,num2str(i+10),'_2'),'png');
    set(gca, 'linewidth', 1.5);
    legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
    print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_2'));
end
axis equal;
print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10 + 1), '_1'));
close(gcf);
im2movie('plot_MBS_2d_xz', dirname);
delete(strcat(dirname, '*.*'));
