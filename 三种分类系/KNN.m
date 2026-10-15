% 手工KNN分类器（无需工具箱）
% 基于KNN的变压器故障诊断
%% 清空环境变量
clc; clear all; close all; warning off;

%% 数据载入
X = xlsread('TFMDE_12345.xlsx');
XP = X;
tic

%% 选取训练数据和测试数据（与PNN代码一致）
Train = XP([1:50, 101:150, 201:250], :);
Test  = XP([51:100, 151:200, 251:300], :);

% 特征和标签（样本行，特征列）
X_train = Train(:, 1:end-1);
Y_train = Train(:, end);          % 训练标签（数值型）
X_test  = Test(:, 1:end-1);
Y_test  = Test(:, end);

% 标签必须为列向量
Y_train = Y_train(:);
Y_test  = Y_test(:);

%% 数据标准化（避免量纲影响，与 fitcknn 的 Standardize 类似）
train_mean = mean(X_train, 1);
train_std  = std(X_train, 0, 1);
X_train_std = (X_train - train_mean) ./ train_std;
X_test_std  = (X_test  - train_mean) ./ train_std;

%% 手工KNN分类器函数（放在同一文件末尾，或另存为 .m 文件）
% 这里将函数定义放在主程序后面，便于直接运行

%% KNN 模型建立（设置 K 值）
K = 5;   % 近邻个数

%% 训练数据回代（仅用于观察训练拟合情况，不代表泛化能力）
Y_train_pred = knn_classify(X_train_std, Y_train, X_train_std, K);

% 绘图：训练集真实标签 vs 预测标签
figure(1)
subplot(1,2,1)
stem(1:length(Y_train_pred), Y_train_pred, 'bo')
hold on
stem(1:length(Y_train), Y_train, 'r*')
xlabel('样本编号'); ylabel('分类结果')
set(gca, 'Ytick', [1:5])
ylim([1 3])                % 根据实际类别数调整
legend('预测标签', '真实标签', 'Location', 'best')
title('训练集回代效果')

subplot(1,2,2)
H_train = Y_train_pred - Y_train;
stem(H_train)
xlabel('样本编号'); ylabel('误差')
title('训练集预测误差')

% 计算训练正确率
train_error = sum(H_train == 0) / length(H_train);

%% 测试集预测
Y_test_pred = knn_classify(X_train_std, Y_train, X_test_std, K);

figure(2)
stem(1:length(Y_test_pred), Y_test_pred, 'b^')
hold on
stem(1:length(Y_test), Y_test, 'r*')
xlabel('预测样本编号'); ylabel('分类结果')
set(gca, 'Ytick', [1:5])
ylim([1 3])
legend('预测标签', '真实标签', 'Location', 'best')
title('KNN 测试集预测效果')

% 计算测试集正确率
H_test = Y_test_pred - Y_test;
test_error = sum(H_test == 0) / length(H_test);

%% 结果输出
disp(['KNN 训练集正确率：', num2str(train_error)])
disp(['KNN 测试集正确率：', num2str(test_error)])
toc

% ========== 手工 KNN 分类函数 ==========
function Y_pred = knn_classify(X_train, Y_train, X_test, K)
% 手工 KNN 分类器（欧氏距离，多分类投票）
% 输入：
%   X_train, X_test : 矩阵，每行一个样本，列是特征
%   Y_train         : 列向量，训练标签（数值型，从1开始编号）
%   K               : 近邻个数
% 输出：
%   Y_pred          : 列向量，预测标签

    n_test = size(X_test, 1);
    Y_pred = zeros(n_test, 1);
    
    for i = 1:n_test
        % 计算当前测试样本与所有训练样本的欧氏距离
        diff = X_train - X_test(i, :);           % 利用广播
        dist = sqrt(sum(diff.^2, 2));
        
        % 排序并取前 K 个最近邻的索引
        [~, idx] = sort(dist);
        neighbors = idx(1:K);
        
        % 从这些邻居的标签中投票（取众数）
        classes = Y_train(neighbors);
        Y_pred(i) = mode(classes);
    end
end