%% 清空环境变量
clc;
clear all
close all 
nntwarn off;
warning off;

%% 数据载入
X = xlsread('TFMDE_12345.xlsx');
XP = X;

tic

%% 选取训练数据和测试数据
Train = XP([1:50, 101:150, 201:250], :);
Test  = XP([51:100, 151:200, 251:300], :);

p_train = Train(:, 1:end-1)';
t_train = Train(:, end)';
p_test  = Test(:, 1:end-1)';
t_test  = Test(:, end)';

%% 将期望类别转换为向量
t_train = ind2vec(t_train);
t_train_temp = Train(:, end)';  

%% 建立PNN网络 + 连续得分输出
Spread = 0.2;
net = newpnn(p_train, t_train, Spread);
net.layers{2}.transferFcn = 'purelin';

%% 训练数据回代
Y = sim(net, p_train);
Yc = vec2ind(compet(Y));

%% 训练集作图
figure(1);
clf
set(gcf, 'Color', 'w', 'Position', [120 120 1180 460], ...
    'Name', '训练集结果', 'NumberTitle', 'off')

subplot(1, 2, 1)
h1 = stem(1:length(Yc), Yc, 'bo');
hold on
h2 = stem(1:length(Yc), t_train_temp, 'r*');
set([h1 h2], 'LineWidth', 1.1, 'MarkerSize', 4)
xlabel('样本编号')
ylabel('分类结果')
title('训练集分类对比')
legend({'预测值', '真实值'}, 'Location', 'best')
grid on
box on
set(gca, 'FontName', 'Microsoft YaHei', 'FontSize', 11, 'LineWidth', 1, 'YTick', 1:3)
xlim([1 length(Yc)])
ylim([0.5 3.5]);

subplot(1, 2, 2)
H = Yc - t_train_temp;
h3 = stem(1:length(H), H, 'k');
hold on
plot([1 length(H)], [0 0], '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 1)
set(h3, 'LineWidth', 1.1, 'MarkerSize', 3)
xlabel('样本编号')
ylabel('预测误差')
title('训练集误差分布')
grid on
box on
set(gca, 'FontName', 'Microsoft YaHei', 'FontSize', 11, 'LineWidth', 1)
xlim([1 length(H)])

% 计算训练正确率
error = sum(abs(H) == 0) / size(H, 2);

%% 测试集预测
Y2 = sim(net, p_test);
Y2c = vec2ind(compet(Y2));
H1 = Y2c - t_test;

%% 测试集作图
figure(2)
clf
set(gcf, 'Color', 'w', 'Position', [120 120 1180 460], ...
    'Name', '测试集结果', 'NumberTitle', 'off')

subplot(1, 2, 1)
h4 = stem(1:length(Y2c), Y2c, 'b^');
hold on
h5 = stem(1:length(Y2c), t_test, 'r*');
set([h4 h5], 'LineWidth', 1.1, 'MarkerSize', 4)
xlabel('预测样本编号')
ylabel('分类结果')
title('测试集分类对比')
legend({'预测值', '真实值'}, 'Location', 'best')
grid on
box on
set(gca, 'FontName', 'Microsoft YaHei', 'FontSize', 11, 'LineWidth', 1, 'YTick', 1:3)
xlim([1 length(Y2c)])
ylim([0.5 3.5]);

subplot(1, 2, 2)
h6 = stem(1:length(H1), H1, 'k');
hold on
plot([1 length(H1)], [0 0], '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 1)
set(h6, 'LineWidth', 1.1, 'MarkerSize', 3)
xlabel('预测样本编号')
ylabel('预测误差')
title('测试集误差分布')
grid on
box on
set(gca, 'FontName', 'Microsoft YaHei', 'FontSize', 11, 'LineWidth', 1)
xlim([1 length(H1)])

% 计算测试集正确率
error1 = sum(abs(H1) == 0) / size(H1, 2);
disp(['RCMDE-PNN训练集正确率：', num2str(error)])
disp(['RCMDE-PNN测试集正确率：', num2str(error1)])

%% ==================== 混淆矩阵 ====================
numClasses  = numel(unique(t_test));
order       = 1:numClasses;
classLabels = arrayfun(@num2str, order, 'UniformOutput', false);
cm = confusionmat(t_test, Y2c, 'Order', order);

% 统一格式参数
fontSize  = 30;
axisWidth = 3;

figCM = figure('Position', [100, 80, 1400, 1050], 'Color', 'w', ...
    'Name', 'Confusion Matrix', 'NumberTitle', 'off');

customColormap = [ ...
    0.95 0.95 1.00;
    0.85 0.85 1.00;
    0.75 0.75 1.00;
    0.65 0.65 1.00;
    0.55 0.55 1.00;
    0.45 0.45 1.00;
    0.35 0.35 1.00;
    0.25 0.25 1.00;
    0.15 0.15 1.00 ];

globalMax = max(cm(:));
if globalMax == 0
    globalMax = 1;
end

imagesc(cm);
colormap(customColormap);
clim([0 globalMax]);

cb = colorbar('FontSize', fontSize, 'FontName', 'Times New Roman', ...
    'FontWeight', 'bold');
cb.LineWidth = axisWidth;

axis image;

set(gca, ...
    'XTick', 1:numClasses, 'YTick', 1:numClasses, ...
    'XTickLabel', classLabels, 'YTickLabel', classLabels, ...
    'FontSize', fontSize, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman', ...
    'XAxisLocation', 'bottom', ...
    'LineWidth', axisWidth, ...
    'Box', 'on', 'TickDir', 'in');

% 单元格数值标注
for row = 1:numClasses
    for col = 1:numClasses
        normalizedValue = cm(row, col) / globalMax;
        colorIndex = min(9, max(1, round(normalizedValue * 8) + 1));
        bgColor = customColormap(colorIndex, :);
        luminance = 0.299 * bgColor(1) + 0.587 * bgColor(2) + 0.114 * bgColor(3);
        if luminance < 0.6
            textColor = [1 1 1];
        else
            textColor = [0 0 0];
        end
        text(col, row, num2str(cm(row, col)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', fontSize, 'FontWeight', 'bold', ...
            'FontName', 'Times New Roman', ...
            'Color', textColor);
    end
end

xlabel('Predicted label', 'FontSize', fontSize, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');
ylabel('True label', 'FontSize', fontSize, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');

% 已删除原顶部标题 title('混淆矩阵', ...)

grid on;
set(gca, 'GridColor', [0.3 0.3 0.3], 'GridAlpha', 0.3);
set(gca, 'Color', [0.98 0.98 0.98]);
%% ==================== 宏平均 ROC 曲线 ====================
figROC = figure('Position', [120, 120, 1100, 780], 'Color', 'w', ...
    'Name', 'Macro-Average ROC', 'NumberTitle', 'off');
hold on

% 统一的 FPR 网格（用于宏平均插值）
fprGrid = linspace(0, 1, 200);
tprAll  = zeros(numClasses, numel(fprGrid));

for k = 1:numClasses
    [fpr_k, tpr_k, ~, ~] = perfcurve(t_test, Y2(k, :)', k);
    fpr_k = fpr_k(:);
    tpr_k = tpr_k(:);
    % 对单调不降的 FPR 去重（interp1 要求 x 严格单调递增）
    [fpr_k, ia] = unique(fpr_k, 'stable');
    tpr_k = tpr_k(ia);
    % 在统一网格上插值
    tprAll(k, :) = interp1(fpr_k, tpr_k, fprGrid, 'linear', 'extrap');
end

% 边界裁到 [0,1]
tprAll(tprAll < 0) = 0;
tprAll(tprAll > 1) = 1;

% 宏平均 TPR
tprMacro = mean(tprAll, 1);

% 宏平均 AUC（梯形积分）
aucMacro = trapz(fprGrid, tprMacro);

% 绘制宏平均 ROC
plot(fprGrid, tprMacro, '-', 'LineWidth', 3.0, 'Color', [0.00 0.45 0.74]);
plot([0 1], [0 1], '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);

box on
axis square
xlim([0 1])
ylim([0 1])

set(gca, 'FontName', 'Times New Roman', 'FontSize', 18, ...
    'LineWidth', 1.2, 'Box', 'on')

xlabel('False Positive Rate', 'FontSize', 18, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');
ylabel('True Positive Rate', 'FontSize', 18, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');
title('Macro-Average ROC Curves', 'FontSize', 20, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');

legend({sprintf('Macro-average (AUC = %.4f)', aucMacro), 'Random'}, ...
    'Location', 'southeast', ...
    'FontName', 'Times New Roman', 'FontSize', 14);

hold off

%% ==================== 修改：仅测试集 t-SNE 降维可视化 ====================
rng(1); % 固定随机种子，结果可复现

% ========== 仅使用测试集特征和标签 ==========
testFeatures = p_test';   % 转置为「样本数 × 特征数」格式，适配tsne
testLabels = t_test(:);   % 测试集标签，转为列向量

% t-SNE 降维到2维（测试集样本量少，困惑度适当调小）
perplexityVal = 25 ;
Y_tsne = tsne(testFeatures, ...
    'Algorithm', 'barneshut', ...
    'Distance', 'euclidean', ...
    'Perplexity', perplexityVal);

% 绘制t-SNE散点图
figTSNE = figure('Position', [120, 120, 900, 750], 'Color', 'w', ...
    'Name', 'Test Set t-SNE', 'NumberTitle', 'off');
ax = axes('Parent', figTSNE);
hold(ax, 'on');

% 三类配色与整套论文图完全统一
tsneColors = [
    76, 176, 69;    % Normal 绿色
    68, 191, 238;  % Interictal 蓝色
    238, 48, 41    % Ictal 红色
] / 255;
classNames = {'Normal', 'Interictal', 'Ictal'};

% 按类别分别绘制散点
for c = 1:3
    idx = testLabels == c;
    scatter(ax, Y_tsne(idx, 1), Y_tsne(idx, 2), 100, ...
        'MarkerFaceColor', tsneColors(c, :), ...
        'MarkerEdgeColor', 'w', ...
        'LineWidth', 0.8, ...
        'MarkerFaceAlpha', 0.85, ...
        'DisplayName', classNames{c});
end

% 坐标轴与样式设置
box(ax, 'on');
grid(ax, 'off');
axis(ax, 'equal');

xlabel(ax, 't-SNE Dimension 1', ...
    'FontName', 'Times New Roman', ...
    'FontSize', 18, ...
    'FontWeight', 'bold');
ylabel(ax, 't-SNE Dimension 2', ...
    'FontName', 'Times New Roman', ...
    'FontSize', 18, ...
    'FontWeight', 'bold');
title(ax, 't-SNE Visualization of Test Set Feature Space', ...
    'FontName', 'Times New Roman', ...
    'FontSize', 20, ...
    'FontWeight', 'bold');

set(ax, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'LineWidth', 1.2);

legend(ax, 'Location', 'best', ...
    'FontName', 'Times New Roman', ...
    'FontSize', 14, ...
    'FontWeight', 'bold', ...
    'Box', 'on');

% 可选：取消注释直接保存高清图
% exportgraphics(figTSNE, 'tSNE_TestSet.png', 'Resolution', 300);

toc