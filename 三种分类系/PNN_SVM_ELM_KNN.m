clc;
clear;
close all;

%% ==================== 数据 ====================
Scale = 1:5;    % 5 个尺度

% ---------- MDE ----------
PNN_MDE  = [94.667, 94.667, 94.667, 94.000, 94.000];
SVM_MDE  = [94.000, 94.000, 94.000, 94.000, 92.000];
ELM_MDE  = [94.667, 94.000, 94.000, 95.333, 93.333];
KNN_MDE  = [94.000, 94.000, 95.333, 94.667, 94.667];

% ---------- TFMDE ----------
PNN_TFMDE = [96.000, 96.000, 96.000, 96.000, 96.667];
SVM_TFMDE = [96.667, 96.667, 97.333, 97.333, 97.333];
ELM_TFMDE = [96.000, 95.333, 95.333, 95.333, 95.333];
KNN_TFMDE = [96.000, 94.667, 94.667, 95.333, 95.333];

%% ==================== 配色 ====================
colorPNN = [0.85, 0.00, 0.65];   % 紫红
colorSVM = [1.00, 0.45, 0.00];   % 橙色
colorELM = [0.00, 0.60, 0.35];   % 墨绿
colorKNN = [0.10, 0.40, 0.80];   % 深蓝

markerPNN = 's';
markerSVM = 'd';
markerELM = '^';
markerKNN = 'o';

% ==================== 统一样式参数 ====================
fontSize  = 30;
axisWidth = 3;
lineWidth = 4.5;
markerSz  = 16;

%% ==================== 图1：MDE ====================
figure('Color', 'w', 'Position', [80, 80, 1100, 850]);
hold on;

plot(Scale, PNN_MDE, ['-' markerPNN], 'Color', colorPNN, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorPNN, 'MarkerEdgeColor', colorPNN);
plot(Scale, SVM_MDE, ['-' markerSVM], 'Color', colorSVM, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorSVM, 'MarkerEdgeColor', colorSVM);
plot(Scale, ELM_MDE, ['-' markerELM], 'Color', colorELM, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorELM, 'MarkerEdgeColor', colorELM);
plot(Scale, KNN_MDE, ['-' markerKNN], 'Color', colorKNN, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorKNN, 'MarkerEdgeColor', colorKNN);

xlim([1, 5]);
ylim([91, 96]);

xticks(1:5);
yticks(91:1:96);

xlabel('Scale', 'FontName', 'Times New Roman', ...
    'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Accuracy (%)', 'FontName', 'Times New Roman', ...
    'FontSize', fontSize, 'FontWeight', 'bold');

lgd = legend({'PNN', 'SVM', 'ELM', 'KNN'}, ...
    'Location', 'southwest', ...
    'FontName', 'Times New Roman', 'FontSize', fontSize - 6, ...
    'FontWeight', 'bold', 'Box', 'on');
lgd.LineWidth = 2;

text(1.15, 95.4, '(a) MDE', ...
    'Color', 'k', 'FontName', 'Times New Roman', ...
    'FontSize', fontSize - 4, 'FontWeight', 'bold');

set(gca, 'FontName', 'Times New Roman', 'FontSize', fontSize, ...
    'FontWeight', 'bold', 'LineWidth', axisWidth, ...
    'Box', 'on', 'TickDir', 'in');
grid off;

hold off;

%% ==================== 图2：TFMDE ====================
figure('Color', 'w', 'Position', [1180, 80, 1100, 850]);
hold on;

plot(Scale, PNN_TFMDE, ['-' markerPNN], 'Color', colorPNN, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorPNN, 'MarkerEdgeColor', colorPNN);
plot(Scale, SVM_TFMDE, ['-' markerSVM], 'Color', colorSVM, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorSVM, 'MarkerEdgeColor', colorSVM);
plot(Scale, ELM_TFMDE, ['-' markerELM], 'Color', colorELM, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorELM, 'MarkerEdgeColor', colorELM);
plot(Scale, KNN_TFMDE, ['-' markerKNN], 'Color', colorKNN, ...
    'LineWidth', lineWidth, 'MarkerSize', markerSz, ...
    'MarkerFaceColor', colorKNN, 'MarkerEdgeColor', colorKNN);

xlim([1, 5]);
ylim([93, 98]);

xticks(1:5);
yticks(93:1:98);

xlabel('Scale', 'FontName', 'Times New Roman', ...
    'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Accuracy (%)', 'FontName', 'Times New Roman', ...
    'FontSize', fontSize, 'FontWeight', 'bold');

lgd = legend({'PNN', 'SVM', 'ELM', 'KNN'}, ...
    'Location', 'southeast', ...
    'FontName', 'Times New Roman', 'FontSize', fontSize - 6, ...
    'FontWeight', 'bold', 'Box', 'on');
lgd.LineWidth = 2;

text(1.15, 97.5, '(b) TFMDE', ...
    'Color', 'k', 'FontName', 'Times New Roman', ...
    'FontSize', fontSize - 4, 'FontWeight', 'bold');

set(gca, 'FontName', 'Times New Roman', 'FontSize', fontSize, ...
    'FontWeight', 'bold', 'LineWidth', axisWidth, ...
    'Box', 'on', 'TickDir', 'in');
grid off;

hold off;