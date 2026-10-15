tic
%初始化程序
close all;
clear;
clc;
format compact;
addpath('libsvm-3.24')

%% 读取数据
data  = xlsread('MDE_45678.xlsx');
data1 = data;
input = data1(:,1:end-1);
output_labels = data1(:,end);

train_input = input([1:50,101:150,201:250],:);
train_output_labels = output_labels([1:50,101:150,201:250],:);
test_input  = input([51:100,151:200,251:300],:);
test_output_labels  = output_labels([51:100,151:200,251:300],:);

%% 数据预处理：归一化到 [0,1]
[mtrain,ntrain] = size(train_input);
[mtest,ntest]   = size(test_input);

dataset = [train_input; test_input];
[dataset_scale,ps] = mapminmax(dataset',0,1);
dataset_scale = dataset_scale';

train_input = dataset_scale(1:mtrain,:);
test_input  = dataset_scale((mtrain+1):(mtrain+mtest),:);

bestc = 1; bestg = 90;

%% SVM 网络训练（开启概率输出 -b 1）
cmd = [' -c ',num2str(bestc),' -g ',num2str(bestg),' -b 1'];
model = libsvmtrain(train_output_labels, train_input, cmd);

%% SVM 网络预测（开启概率输出）
[predict_label, accuracy, prob_estimates] = ...
    libsvmpredict(test_output_labels, test_input, model, ' -b 1');

%% 分类对比图
figure;
hold on;
plot(test_output_labels,'o');
plot(predict_label,'r*');
xlabel('测试集样本','FontSize',12);
ylabel('类别标签','FontSize',12);
legend('实际测试集分类','预测测试集分类');
title({['Accuracy = ',num2str(accuracy(1)),'%']},'FontSize',12);
grid on;

%% 打印结果
disp(' ')
disp('样本编号  真实类型  预测类型')
for i = 1:length(test_output_labels)
    disp([i test_output_labels(i) predict_label(i)])
end

%% ==================== 统一参数 ====================
fontSize  = 30;
axisWidth = 3;
lineWidth = 4.5;
markerSz  = 12;

numClasses  = numel(unique(test_output_labels));
order       = 1:numClasses;
classLabels = arrayfun(@num2str, order, 'UniformOutput', false);

%% ==================== 1. 混淆矩阵 ====================
cm = confusionmat(test_output_labels, predict_label, 'Order', order);

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
if globalMax == 0, globalMax = 1; end

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
    'LineWidth', axisWidth, 'Box', 'on', 'TickDir', 'in');

for row = 1:numClasses
    for col = 1:numClasses
        nv = cm(row, col) / globalMax;
        ci = min(9, max(1, round(nv * 8) + 1));
        bgColor = customColormap(ci, :);
        lum = 0.299*bgColor(1) + 0.587*bgColor(2) + 0.114*bgColor(3);
        if lum < 0.6, textColor = [1 1 1]; else, textColor = [0 0 0]; end
        text(col, row, num2str(cm(row, col)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', fontSize, 'FontWeight', 'bold', ...
            'FontName', 'Times New Roman', 'Color', textColor);
    end
end

xlabel('Predicted label', 'FontSize', fontSize, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');
ylabel('True label', 'FontSize', fontSize, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');

grid on;
set(gca, 'GridColor', [0.3 0.3 0.3], 'GridAlpha', 0.3);
set(gca, 'Color', [0.98 0.98 0.98]);

%% ==================== 2. 宏平均 ROC 曲线 ====================
scoreAll = zeros(numel(test_output_labels), numClasses);
for k = 1:numClasses
    clsIdx = find(model.Label == k, 1);
    if ~isempty(clsIdx)
        scoreAll(:, k) = prob_estimates(:, clsIdx);
    end
end

figROC = figure('Position', [120, 120, 1000, 900], 'Color', 'w', ...
    'Name', 'Macro-Average ROC', 'NumberTitle', 'off');
hold on

fprGrid = linspace(0, 1, 200);
tprAll  = zeros(numClasses, numel(fprGrid));

for k = 1:numClasses
    [fpr_k, tpr_k, ~, ~] = perfcurve(test_output_labels, scoreAll(:,k), k);
    fpr_k = fpr_k(:); tpr_k = tpr_k(:);
    [fpr_k, ia] = unique(fpr_k, 'stable');
    tpr_k = tpr_k(ia);
    tprAll(k, :) = interp1(fpr_k, tpr_k, fprGrid, 'linear', 'extrap');
end

tprAll(tprAll < 0) = 0;
tprAll(tprAll > 1) = 1;
tprMacro = mean(tprAll, 1);
aucMacro = trapz(fprGrid, tprMacro);

plot([0 1], [0 1], '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 3.0);
plot(fprGrid, tprMacro, '-', 'Color', [0.00 0.45 0.74], 'LineWidth', lineWidth);

grid on
set(gca, 'GridColor', [0.75 0.75 0.75], 'GridAlpha', 0.9, ...
    'GridLineStyle', '-', 'Layer', 'top');
box on
axis square
xlim([0 1]); ylim([0 1]);

set(gca, 'FontName', 'Times New Roman', 'FontSize', fontSize, ...
    'FontWeight', 'bold', 'LineWidth', axisWidth, 'Box', 'on', ...
    'TickDir', 'in', 'XTick', 0:0.2:1, 'YTick', 0:0.2:1);

xlabel('False Positive Rate', 'FontSize', fontSize, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');
ylabel('True Positive Rate', 'FontSize', fontSize, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');

lgd = legend({sprintf('Macro-average ROC (AUC = %.4f)', aucMacro), 'Random'}, ...
    'Location', 'southeast', 'FontName', 'Times New Roman', ...
    'FontSize', 20, 'FontWeight', 'bold', 'Box', 'on');
lgd.LineWidth = 2;

hold off

%% ==================== 3. 由混淆矩阵计算 P/R/F1 ====================
precision = zeros(numClasses, 1);
recall    = zeros(numClasses, 1);
f1        = zeros(numClasses, 1);

for k = 1:numClasses
    TP = cm(k, k);
    FP = sum(cm(:, k)) - TP;
    FN = sum(cm(k, :)) - TP;
    if (TP + FP) > 0, precision(k) = TP / (TP + FP); end
    if (TP + FN) > 0, recall(k)    = TP / (TP + FN); end
    if (precision(k) + recall(k)) > 0
        f1(k) = 2 * precision(k) * recall(k) / (precision(k) + recall(k));
    end
end

macroP  = mean(precision);
macroR  = mean(recall);
macroF1 = mean(f1);

fprintf('\n%-6s %10s %10s %10s\n', 'Class', 'Precision', 'Recall', 'F1');
for k = 1:numClasses
    fprintf('%-6d %10.4f %10.4f %10.4f\n', k, precision(k), recall(k), f1(k));
end
fprintf('%-6s %10.4f %10.4f %10.4f\n', 'Macro', macroP, macroR, macroF1);

toc