n = size(MBS.data, 2);
m = size(MBS.data{1, 1}, 2);
dirname = 'moviepic\';
% set(gcf,'position',[50,50,1600,1200]);
view(-37.5, 30);
if m < 3
    for i = 1:n
        X = [MBS.data{1, i}(1, 1); MBS.data{1, i}(end, 1)];
        Y = [MBS.data{1, i}(1, 2); MBS.data{1, i}(end, 2)];

        %         axis equal;
        pause(0.1)
        plot(MBS.data{1, i}(:, 1), MBS.data{1, i}(:, 2), ...
             '.k', 'MarkerSize', 20); hold on;
        title('Dynamically estimation of Maximal Blurred Segment')
        xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold');
        set(gca, 'linewidth', 1.5);
        legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
        print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_1'));
        %         axis equal;
        plot(X, Y, 'pk', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); hold on; grid on;
        plot(X, Y, '-b', 'MarkerSize', 10); hold on; grid on;
        set(gca, 'linewidth', 1.5);
        xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold');
        legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
        print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_2'));
    end
    axis equal;
    print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10 + 1), '_1'));
    close(gcf);
    im2movie('plot_MBS_2d_xy', dirname);
    delete(strcat(dirname, '*.*'));
else
    for i = 1:n
        X = [MBS.data{1, i}(1, 1); MBS.data{1, i}(end, 1)];
        Y = [MBS.data{1, i}(1, 2); MBS.data{1, i}(end, 2)];
        Z = [MBS.data{1, i}(1, 3); MBS.data{1, i}(end, 3)];
        %         axis equal;
        pause(0.1)
        plot3(MBS.data{1, i}(:, 1), MBS.data{1, i}(:, 2), MBS.data{1, i}(:, 3), ...
              '.k', 'MarkerSize', 20); hold on; grid on;
        title('Dynamically estimation of Maximal Blurred Segment')
        xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold'); zlabel('Z', 'FontWeight', 'bold');
        legend('Original trajectory', 'Estimated key points');
        set(gca, 'linewidth', 1.5);
        h = legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
        set(h, 'Location', 'NorthEast');
        print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_1'));
        %         axis equal;
        plot3(X, Y, Z, 'pk', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); hold on; grid on;
        plot3(X, Y, Z, '-b', 'MarkerSize', 10); hold on; grid on;
        xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold'); zlabel('Z', 'FontWeight', 'bold');
        h = legend('Discrete trajectory', 'Estimated key points on trajectory', 'Estimated dicrete lines');
        set(h, 'Location', 'NorthEast');
        set(gca, 'linewidth', 1.5);
        print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10), '_2'));
    end
    axis equal;
    print(gcf, '-dtiff', '-r300', strcat(dirname, num2str(i + 10 + 1), '_1'));
    close(gcf);
    im2movie('plot_MBS', dirname);
    delete(strcat(dirname, '*.*'));
end
