% RCMDE-ELM
% 基于RCMDE特征的变压器故障诊断 - ELM分类
clc;
clearvars;
close all;
warning off;

tic

X = xlsread('TFMDE_12345.xlsx');

Train = X([1:50, 101:150, 201:250], :);
Test  = X([51:100, 151:200, 251:300], :);

p_train = Train(:, 1:end-1);
t_train = Train(:, end);
p_test  = Test(:, 1:end-1);
t_test  = Test(:, end);

classOrder = unique(t_train(:))';
outDir = fullfile(pwd, 'ELM_Output');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

rng(1);
hiddenNum = 80;
ridge = 1e-3;
[elmModel, trainPred, trainScore] = train_elm_classifier(p_train, t_train, classOrder, hiddenNum, ridge);
[testPred, testScore] = predict_elm_classifier(elmModel, p_test);

trainAcc = mean(trainPred == t_train);
testAcc = mean(testPred == t_test);

plot_compare_result(1, '训练集结果 - ELM', '训练集分类对比', '训练集误差分布', ...
    trainPred, t_train, 'bo', fullfile(outDir, 'compare_train_elm.png'));
plot_compare_result(2, '测试集结果 - ELM', '测试集分类对比', '测试集误差分布', ...
    testPred, t_test, 'b^', fullfile(outDir, 'compare_test_elm.png'));

plot_confusion_heatmap(classOrder, t_test, testPred, ...
    '混淆矩阵 - ELM', '混淆矩阵', fullfile(outDir, 'confusion_elm.png'));
plot_multi_roc(classOrder, t_test, testScore, ...
    'ROC曲线 - ELM', 'ROC Curves', fullfile(outDir, 'roc_elm.png'));

disp(['RCMDE-ELM训练集正确率：', num2str(trainAcc)]);
disp(['RCMDE-ELM测试集正确率：', num2str(testAcc)]);

toc

function [model, trainPred, trainScore] = train_elm_classifier(XTrain, yTrain, classOrder, hiddenNum, ridge)
XTrain = double(XTrain);
yTrain = double(yTrain(:));

mu = mean(XTrain, 1);
sigma = std(XTrain, 0, 1);
sigma(sigma == 0) = 1;
XNorm = (XTrain - mu) ./ sigma;

nFeatures = size(XNorm, 2);
nClasses = numel(classOrder);

inputWeight = randn(nFeatures, hiddenNum);
bias = randn(1, hiddenNum);

hiddenOutput = sigmoid(XNorm * inputWeight + bias);
targets = one_hot_encode(yTrain, classOrder);

beta = (hiddenOutput' * hiddenOutput + ridge * eye(hiddenNum)) \ (hiddenOutput' * targets);
trainScore = softmax_rows(hiddenOutput * beta);
[~, idx] = max(trainScore, [], 2);
trainPred = classOrder(idx);
trainPred = trainPred(:);

model.mu = mu;
model.sigma = sigma;
model.inputWeight = inputWeight;
model.bias = bias;
model.beta = beta;
model.classOrder = classOrder;
model.hiddenNum = hiddenNum;
model.nClasses = nClasses;
end

function [predLabels, scoreMatrix] = predict_elm_classifier(model, X)
X = double(X);
XNorm = (X - model.mu) ./ model.sigma;
hiddenOutput = sigmoid(XNorm * model.inputWeight + model.bias);
scoreMatrix = softmax_rows(hiddenOutput * model.beta);
[~, idx] = max(scoreMatrix, [], 2);
predLabels = model.classOrder(idx);
predLabels = predLabels(:);
end

function T = one_hot_encode(labels, classOrder)
labels = labels(:);
nSamples = numel(labels);
nClasses = numel(classOrder);
T = zeros(nSamples, nClasses);
for i = 1:nSamples
    col = find(classOrder == labels(i), 1);
    T(i, col) = 1;
end
end

function Y = softmax_rows(X)
X = X - max(X, [], 2);
expX = exp(X);
Y = expX ./ sum(expX, 2);
end

function Y = sigmoid(X)
Y = 1 ./ (1 + exp(-X));
end

function plot_compare_result(figNum, figName, compareTitle, errorTitle, predLabels, trueLabels, predMarker, outFile)
predLabels = predLabels(:);
trueLabels = trueLabels(:);

figure(figNum);
clf;
set(gcf, 'Color', 'w', 'Position', [120 120 1180 460], ...
    'Name', figName, 'NumberTitle', 'off');

subplot(1, 2, 1)
h1 = stem(1:numel(predLabels), predLabels, predMarker);
hold on
h2 = stem(1:numel(trueLabels), trueLabels, 'r*');
set([h1 h2], 'LineWidth', 1.1, 'MarkerSize', 4)
xlabel('样本编号')
ylabel('分类结果')
title(compareTitle)
legend({'预测值', '真实值'}, 'Location', 'best')
grid on
box on
set(gca, 'FontName', 'Microsoft YaHei', 'FontSize', 11, 'LineWidth', 1, 'YTick', 1:3)
xlim([1 numel(predLabels)])
ylim([0.5 3.5]);

subplot(1, 2, 2)
H = predLabels - trueLabels;
h3 = stem(1:numel(H), H, 'k');
hold on
plot([1 numel(H)], [0 0], '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 1)
set(h3, 'LineWidth', 1.1, 'MarkerSize', 3)
xlabel('样本编号')
ylabel('预测误差')
title(errorTitle)
grid on
box on
set(gca, 'FontName', 'Microsoft YaHei', 'FontSize', 11, 'LineWidth', 1)
xlim([1 numel(H)])

if nargin >= 8 && ~isempty(outFile)
    saveas(gcf, outFile);
end
end

function plot_confusion_heatmap(classOrder, trueLabels, predLabels, figName, figTitle, outFile)
trueLabels = trueLabels(:);
predLabels = predLabels(:);
cm = confusionmat(trueLabels, predLabels, 'Order', classOrder);
numClasses = numel(classOrder);
classLabels = arrayfun(@num2str, classOrder, 'UniformOutput', false);

figure('Position', [100, 100, 1200, 820], 'Color', 'w', ...
    'Name', figName, 'NumberTitle', 'off');

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
caxis([0 globalMax]);
colorbar('FontSize', 18, 'FontName', 'Times New Roman');
axis image;

set(gca, ...
    'XTick', 1:numClasses, 'YTick', 1:numClasses, ...
    'XTickLabel', classLabels, 'YTickLabel', classLabels, ...
    'FontSize', 18, 'FontWeight', 'bold', ...
    'FontName', 'Times New Roman', ...
    'XAxisLocation', 'bottom', ...
    'Box', 'on');

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
            'FontSize', 18, 'FontWeight', 'bold', ...
            'FontName', 'Times New Roman', ...
            'Color', textColor);
    end
end

xlabel('预测标签', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('真实标签', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title(figTitle, 'FontSize', 20, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;
set(gca, 'GridColor', [0.3 0.3 0.3], 'GridAlpha', 0.3);
set(gca, 'Color', [0.98 0.98 0.98]);

if nargin >= 6 && ~isempty(outFile)
    saveas(gcf, outFile);
end
end

function aucValues = plot_multi_roc(classOrder, trueLabels, scoreMatrix, figName, figTitle, outFile)
trueLabels = trueLabels(:);

figure('Position', [120, 120, 1100, 780], 'Color', 'w', ...
    'Name', figName, 'NumberTitle', 'off');
hold on

rocColors = [0.00 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19];
numClasses = numel(classOrder);
aucValues = zeros(1, numClasses);

for k = 1:numClasses
    [fpr, tpr, ~, aucValues(k)] = perfcurve(trueLabels, scoreMatrix(:, k), classOrder(k));
    plot(fpr, tpr, 'LineWidth', 2.6, 'Color', rocColors(k, :));
end

plot([0 1], [0 1], '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
box on
axis square
xlim([0 1])
ylim([0 1])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 18, 'LineWidth', 1.2, 'Box', 'on')
xlabel('False Positive Rate', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('True Positive Rate', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title(figTitle, 'FontSize', 20, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

legendStrings = cell(1, numClasses);
for k = 1:numClasses
    legendStrings{k} = sprintf('Class %d (AUC = %.4f)', classOrder(k), aucValues(k));
end
legend([legendStrings, {'Random'}], 'Location', 'southeast');

if nargin >= 6 && ~isempty(outFile)
    saveas(gcf, outFile);
end
end
