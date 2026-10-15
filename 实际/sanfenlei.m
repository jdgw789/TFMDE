clc;
clear all;
close all;
nntwarn off;
warning off;

% 读取数据
data1 = xlsread('清醒.xlsx');
data2 = xlsread('疲劳.xlsx');
data3 = xlsread('嗜睡.xlsx');

a = data1';
b = data2';
d = data3';

% 参数设置
m = 3;
tau = 1;
Scale = 20;
c = 4;

% ==================== 1. 原版 MDE ====================
tic
for i = 1:100
    Out_MDE1(:,i) = MDE(a(i,1:1024), m, c, tau, Scale);
    Out_MDE2(:,i) = MDE(b(i,1:1024), m, c, tau, Scale);
    Out_MDE3(:,i) = MDE(d(i,1:1024), m, c, tau, Scale);
end
toc

% ==================== 2. TFMDE（替代 RCMDE） ====================
tic
for i = 1:100
    Out_TFMDE1(:,i) = TFMDE(a(i,1:1024), m, c, tau, Scale);
    Out_TFMDE2(:,i) = TFMDE(b(i,1:1024), m, c, tau, Scale);
    Out_TFMDE3(:,i) = TFMDE(d(i,1:1024), m, c, tau, Scale);
end
toc

% ==================== 均值与方差 ====================
% MDE 统计量
muMDE1 = mean(Out_MDE1, 2);   stdMDE1 = std(Out_MDE1, 0, 2);
muMDE2 = mean(Out_MDE2, 2);   stdMDE2 = std(Out_MDE2, 0, 2);
muMDE3 = mean(Out_MDE3, 2);   stdMDE3 = std(Out_MDE3, 0, 2);

% TFMDE 统计量
muTFMDE1 = mean(Out_TFMDE1, 2); stdTFMDE1 = std(Out_TFMDE1, 0, 2);
muTFMDE2 = mean(Out_TFMDE2, 2); stdTFMDE2 = std(Out_TFMDE2, 0, 2);
muTFMDE3 = mean(Out_TFMDE3, 2); stdTFMDE3 = std(Out_TFMDE3, 0, 2);

% ==================== 绘图 ====================
x = 1:length(muMDE1);

% 参考图配色
colorBlue   = [0.42 0.62 0.82];   % 浅蓝
colorPurple = [0.38 0.32 0.58];   % 深紫
colorPink   = [0.90 0.58 0.72];   % 粉色

% 统一格式参数
fontSize   = 30;
lineWidth  = 4.5;
axisWidth  = 3;

% 图1：MDE
figure(1)
errorbar(x, muMDE1, stdMDE1, '-^', 'Color', colorBlue, ...
    'LineWidth', lineWidth, 'MarkerSize', 10, 'MarkerFaceColor', colorBlue)
hold on
errorbar(x, muMDE2, stdMDE2, '-v', 'Color', colorPurple, ...
    'LineWidth', lineWidth, 'MarkerSize', 10, 'MarkerFaceColor', colorPurple)
errorbar(x, muMDE3, stdMDE3, '-s', 'Color', colorPink, ...
    'LineWidth', lineWidth, 'MarkerSize', 10, 'MarkerFaceColor', colorPink)

legend('Awake', 'Fatigue', 'Drowsy', ...
    'FontSize', fontSize, 'FontWeight', 'bold');
xlabel('Scale factor', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('MDE',          'FontSize', fontSize, 'FontWeight', 'bold');

set(gca, 'FontSize', fontSize, 'FontWeight', 'bold', 'LineWidth', axisWidth);
set(gca, 'Box', 'on', 'TickDir', 'in');
hold off

% 图2：TFMDE
figure(2)
errorbar(x, muTFMDE1, stdTFMDE1, '-^', 'Color', colorBlue, ...
    'LineWidth', lineWidth, 'MarkerSize', 10, 'MarkerFaceColor', colorBlue)
hold on
errorbar(x, muTFMDE2, stdTFMDE2, '-v', 'Color', colorPurple, ...
    'LineWidth', lineWidth, 'MarkerSize', 10, 'MarkerFaceColor', colorPurple)
errorbar(x, muTFMDE3, stdTFMDE3, '-s', 'Color', colorPink, ...
    'LineWidth', lineWidth, 'MarkerSize', 10, 'MarkerFaceColor', colorPink)

legend('Awake', 'Fatigue', 'Drowsy', ...
    'FontSize', fontSize, 'FontWeight', 'bold');
xlabel('Scale factor', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('TFMDE',        'FontSize', fontSize, 'FontWeight', 'bold');

set(gca, 'FontSize', fontSize, 'FontWeight', 'bold', 'LineWidth', axisWidth);
set(gca, 'Box', 'on', 'TickDir', 'in');
hold off