clc;
clear;
close all;

rng(1);

scriptDir = fileparts(mfilename('fullpath'));
if ~isempty(scriptDir)
    parentDir = fileparts(scriptDir);
    if ~isempty(parentDir)
        addpath(parentDir);
    end
    addpath(scriptDir);
end

% Logistic map:
%   x(n+1) = lambda * x(n) * (1 - x(n))
lambdaVec = 3.5:0.0004:3.8;
nLambda = numel(lambdaVec);

N = 2000;
discard = 800;
tailLen = 800;

% Entropy parameters shared by MDE and TFMDE
entropyParam.mList = [3 4 5];
entropyParam.cList = 3;
entropyParam.tau = 1;
entropyParam.Scale = 6;

seriesCell = cell(1, nLambda);
bifCell = cell(1, nLambda);

for i = 1:nLambda
    x = logistic_map(lambdaVec(i), N, 0.2);
    x = x(discard + 1:end);
    seriesCell{i} = x;
    bifCell{i} = x(max(1, numel(x) - tailLen + 1):end);
end

nM = numel(entropyParam.mList);

MDECurves = NaN(nM, nLambda);
TFMDECurves = NaN(nM, nLambda);

for im = 1:nM
    m = entropyParam.mList(im);
    c = entropyParam.cList(1);
    deMax = log(c^m);
    for i = 1:nLambda
        x = seriesCell{i};
        MDEvec = MDE(x, m, c, entropyParam.tau, entropyParam.Scale);
        TFMDEvec = TFMDE(x, m, c, entropyParam.tau, entropyParam.Scale);
        MDECurves(im, i) = mean(MDEvec ./ deMax, 'omitnan');
        TFMDECurves(im, i) = mean(TFMDEvec ./ deMax, 'omitnan');
    end
end

% 统一样式
fontSize       = 30;
axisLineWidth  = 3;
curveLineWidth = 1.5;   % 曲线线宽

% -------------------------- 图1：MDE --------------------------
figure('Position', [100 30 1000 1600]);

for im = 1:nM
    subplot(5, 1, im);
    plot(lambdaVec, MDECurves(im, :), 'k-', 'LineWidth', curveLineWidth);
    grid on;
    xlim([min(lambdaVec) max(lambdaVec)]);
    ylim([0 1]);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', fontSize, ...
        'FontWeight', 'bold', 'LineWidth', axisLineWidth, 'Box', 'on');
    ylabel('Entropy', 'FontName', 'Times New Roman', ...
        'FontSize', fontSize, 'FontWeight', 'bold');
    if im == 1
        legend('MDE', 'Location', 'northwest', ...
            'FontName', 'Times New Roman', 'FontSize', fontSize, ...
            'FontWeight', 'bold');
    end
end

subplot(5, 1, 4:5);
hold on;
for i = 1:nLambda
    x = bifCell{i};
    lam = lambdaVec(i);
    plot(lam * ones(size(x)), x, '.b', 'MarkerSize', 2);
end
grid on;

xlabel('\lambda', 'FontName', 'Times New Roman', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('x', 'FontName', 'Times New Roman', 'FontSize', fontSize, 'FontWeight', 'bold');

set(gca, 'FontName', 'Times New Roman', 'FontSize', fontSize, ...
    'FontWeight', 'bold', 'LineWidth', axisLineWidth, 'Box', 'on');

xlim([min(lambdaVec) max(lambdaVec)]);
ylim([0 1]);

% -------------------------- 图2：TFMDE --------------------------
figure('Position', [1150 30 1000 1600]);

for im = 1:nM
    subplot(5, 1, im);
    plot(lambdaVec, TFMDECurves(im, :), 'r-', 'LineWidth', curveLineWidth);
    grid on;
    xlim([min(lambdaVec) max(lambdaVec)]);
    ylim([0 1]);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', fontSize, ...
        'FontWeight', 'bold', 'LineWidth', axisLineWidth, 'Box', 'on');
    ylabel('Entropy', 'FontName', 'Times New Roman', ...
        'FontSize', fontSize, 'FontWeight', 'bold');
    if im == 1
        legend('TFMDE', 'Location', 'northwest', ...
            'FontName', 'Times New Roman', 'FontSize', fontSize, ...
            'FontWeight', 'bold');
    end
end

subplot(5, 1, 4:5);
hold on;
for i = 1:nLambda
    x = bifCell{i};
    lam = lambdaVec(i);
    plot(lam * ones(size(x)), x, '.b', 'MarkerSize', 2);
end
grid on;

xlabel('\lambda', 'FontName', 'Times New Roman', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('x', 'FontName', 'Times New Roman', 'FontSize', fontSize, 'FontWeight', 'bold');

set(gca, 'FontName', 'Times New Roman', 'FontSize', fontSize, ...
    'FontWeight', 'bold', 'LineWidth', axisLineWidth, 'Box', 'on');

xlim([min(lambdaVec) max(lambdaVec)]);
ylim([0 1]);

% 工具函数
function x = logistic_map(lambda, N, x0)
x = zeros(1, N);
x(1) = x0;
for n = 1:N-1
    x(n + 1) = lambda * x(n) * (1 - x(n));
end
end