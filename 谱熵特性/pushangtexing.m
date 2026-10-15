%% =========================================================
% 真实EEG三状态分析
%
% Excel文件与本代码位于同一文件夹：
%   清醒.xlsx
%   疲劳.xlsx
%   嗜睡.xlsx
%
% 每个Excel文件：
%   1024行 × 100列
%
% 数据含义：
%   每一列 = 一段EEG信号
%   每一段EEG = 1024个采样点
%
% 本代码功能：
%   1. 读取清醒、疲劳、嗜睡三个Excel文件
%   2. 计算Welch功率谱
%   3. 计算归一化谱熵
%   4. 计算Delta、Theta、Alpha、Beta、Gamma频带功率
%   5. 绘制代表性EEG信号
%   6. 绘制谱熵均值柱状图（三色）
%   7. 进行ANOVA检验
%
% 注意：
%   本代码只读取Excel中的真实EEG数据，
%   不生成任何模拟EEG信号。
%% =========================================================

clear;
clc;
close all;

%% ===================== 1. 基本参数 =====================

codeFolder = fileparts(mfilename('fullpath'));
if isempty(codeFolder)
    codeFolder = pwd;
end

awakeFile   = fullfile(codeFolder, '清醒.xlsx');
fatigueFile = fullfile(codeFolder, '疲劳.xlsx');
drowsyFile  = fullfile(codeFolder, '嗜睡.xlsx');

fs = 256;

expectedSamples = 1024;
expectedEpochs  = 100;

sheetName = 1;
hasHeader = false;

analysisBand = [0.5 45];
welchWindowSeconds = 4;
welchOverlapRatio = 0.5;

%% ===================== 2. 检查文件是否存在 =====================

if ~isfile(awakeFile)
    error('找不到清醒状态文件：%s', awakeFile);
end
if ~isfile(fatigueFile)
    error('找不到疲劳状态文件：%s', fatigueFile);
end
if ~isfile(drowsyFile)
    error('找不到嗜睡状态文件：%s', drowsyFile);
end

fprintf('当前代码目录：\n%s\n\n', codeFolder);
fprintf('读取文件：\n');
fprintf('清醒：%s\n', awakeFile);
fprintf('疲劳：%s\n', fatigueFile);
fprintf('嗜睡：%s\n\n', drowsyFile);

%% ===================== 3. 读取三个Excel文件 =====================

awakeEpochs = loadEEGExcelFile( ...
    awakeFile, sheetName, hasHeader, ...
    expectedSamples, expectedEpochs);

fatigueEpochs = loadEEGExcelFile( ...
    fatigueFile, sheetName, hasHeader, ...
    expectedSamples, expectedEpochs);

drowsyEpochs = loadEEGExcelFile( ...
    drowsyFile, sheetName, hasHeader, ...
    expectedSamples, expectedEpochs);

fprintf('\nExcel数据读取完成：\n');
fprintf('清醒状态：%d段EEG\n', length(awakeEpochs));
fprintf('疲劳状态：%d段EEG\n', length(fatigueEpochs));
fprintf('嗜睡状态：%d段EEG\n', length(drowsyEpochs));

if isempty(awakeEpochs)
    error('清醒状态没有读取到有效EEG数据。');
end
if isempty(fatigueEpochs)
    error('疲劳状态没有读取到有效EEG数据。');
end
if isempty(drowsyEpochs)
    error('嗜睡状态没有读取到有效EEG数据。');
end

%% ===================== 4. 数据预处理 =====================

awakeEpochs = preprocessEpochs(awakeEpochs);
fatigueEpochs = preprocessEpochs(fatigueEpochs);
drowsyEpochs = preprocessEpochs(drowsyEpochs);

fprintf('\n预处理后的数据数量：\n');
fprintf('清醒：%d段\n', length(awakeEpochs));
fprintf('疲劳：%d段\n', length(fatigueEpochs));
fprintf('嗜睡：%d段\n', length(drowsyEpochs));

%% ===================== 5. EEG频带设置 =====================

bands = [
    0.5  4;
    4    8;
    8    13;
    13   30;
    30   45
];

bandNames = {'Delta','Theta','Alpha','Beta','Gamma'};

%% ===================== 6. 计算功率谱和谱熵 =====================

fprintf('\n开始计算清醒状态特征...\n');
[awakePSD, freqAxis, awakeEntropy, awakeBandPower] = ...
    calculateStateFeatures( ...
    awakeEpochs, fs, analysisBand, ...
    welchWindowSeconds, welchOverlapRatio, bands);

fprintf('开始计算疲劳状态特征...\n');
[fatiguePSD, ~, fatigueEntropy, fatigueBandPower] = ...
    calculateStateFeatures( ...
    fatigueEpochs, fs, analysisBand, ...
    welchWindowSeconds, welchOverlapRatio, bands);

fprintf('开始计算嗜睡状态特征...\n');
[drowsyPSD, ~, drowsyEntropy, drowsyBandPower] = ...
    calculateStateFeatures( ...
    drowsyEpochs, fs, analysisBand, ...
    welchWindowSeconds, welchOverlapRatio, bands);

%% ===================== 7. 删除无效结果 =====================

validAwake = isfinite(awakeEntropy);
validFatigue = isfinite(fatigueEntropy);
validDrowsy = isfinite(drowsyEntropy);

awakePSD = awakePSD(validAwake, :);
fatiguePSD = fatiguePSD(validFatigue, :);
drowsyPSD = drowsyPSD(validDrowsy, :);

awakeEntropy = awakeEntropy(validAwake);
fatigueEntropy = fatigueEntropy(validFatigue);
drowsyEntropy = drowsyEntropy(validDrowsy);

awakeBandPower = awakeBandPower(validAwake, :);
fatigueBandPower = fatigueBandPower(validFatigue, :);
drowsyBandPower = drowsyBandPower(validDrowsy, :);

fprintf('\n有效特征数量：\n');
fprintf('清醒：%d段\n', length(awakeEntropy));
fprintf('疲劳：%d段\n', length(fatigueEntropy));
fprintf('嗜睡：%d段\n', length(drowsyEntropy));

%% ===================== 8. 绘制代表性EEG信号 =====================

figure('Color','w','Position',[100 100 1200 800]);

timeAwake = (0:length(awakeEpochs{1})-1) / fs;
timeFatigue = (0:length(fatigueEpochs{1})-1) / fs;
timeDrowsy = (0:length(drowsyEpochs{1})-1) / fs;

subplot(3,1,1);
plot(timeAwake, awakeEpochs{1}, 'b', 'LineWidth', 1);
xlabel('Time / s');
ylabel('Amplitude');
title('Representative Awake EEG');
grid on;

subplot(3,1,2);
plot(timeFatigue, fatigueEpochs{1}, 'r', 'LineWidth', 1);
xlabel('Time / s');
ylabel('Amplitude');
title('Representative Fatigue EEG');
grid on;

subplot(3,1,3);
plot(timeDrowsy, drowsyEpochs{1}, 'm', 'LineWidth', 1);
xlabel('Time / s');
ylabel('Amplitude');
title('Representative Drowsy EEG');
grid on;

% ★ 谱熵分布图已删除

%% ===================== 12. 谱熵均值和标准差（三色柱状图） =====================

meanEntropy = [
    mean(awakeEntropy, 'omitnan');
    mean(fatigueEntropy, 'omitnan');
    mean(drowsyEntropy, 'omitnan')
];

stdEntropy = [
    std(awakeEntropy, 'omitnan');
    std(fatigueEntropy, 'omitnan');
    std(drowsyEntropy, 'omitnan')
];

% 三种不同颜色
barColors = [
    0.42 0.62 0.82;   % Awake    浅钢蓝
    0.90 0.58 0.72;   % Fatigue  玫瑰粉
    0.38 0.32 0.58    % Drowsy   深紫
];

fontSize  = 26;
axisWidth = 3;

figBar = figure('Color','w','Position',[300 250 1000 700]);
ax = axes('Parent', figBar);
hold(ax, 'on');

b = bar(ax, 1:3, meanEntropy, 0.55);
b.FaceColor = 'flat';
b.CData = barColors;
b.EdgeColor = 'k';
b.LineWidth = axisWidth;

errorbar(ax, 1:3, meanEntropy, stdEntropy, ...
    'k', 'LineStyle','none', ...
    'LineWidth', axisWidth, 'CapSize', 18);

% 柱顶数值标注
for i = 1:3
    text(ax, i, meanEntropy(i) + stdEntropy(i) + 0.005, ...
        sprintf('%.4f', meanEntropy(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontName', 'Times New Roman', ...
        'FontSize', fontSize-4, 'FontWeight', 'bold');
end

set(ax, ...
    'XTick', 1:3, ...
    'XTickLabel', {'Awake','Fatigue','Drowsy'}, ...
    'FontName', 'Times New Roman', ...
    'FontSize', fontSize, ...
    'FontWeight', 'bold', ...
    'LineWidth', axisWidth, ...
    'Box', 'on', 'TickDir', 'in');

ylabel(ax, 'Normalized Spectral Entropy', ...
    'FontName', 'Times New Roman', ...
    'FontSize', fontSize, 'FontWeight', 'bold');

title(ax, 'Mean Spectral Entropy', ...
    'FontName', 'Times New Roman', ...
    'FontSize', fontSize, 'FontWeight', 'bold');

ylim(ax, [0 1.05]);
grid(ax, 'on');
set(ax, 'GridAlpha', 0.3);

hold(ax, 'off');

%% ===================== 统计检验：单因素ANOVA =====================

awakeData = awakeEntropy(isfinite(awakeEntropy));
fatigueData = fatigueEntropy(isfinite(fatigueEntropy));
drowsyData = drowsyEntropy(isfinite(drowsyEntropy));

if isempty(awakeData) || isempty(fatigueData) || isempty(drowsyData)
    error('至少有一个状态没有有效的谱熵数据，无法进行ANOVA检验。');
end

groupData = {
    awakeData(:), ...
    fatigueData(:), ...
    drowsyData(:)
};

groupNames = {'Awake','Fatigue','Drowsy'};

n1 = length(awakeData);
n2 = length(fatigueData);
n3 = length(drowsyData);

N = n1 + n2 + n3;
k = 3;

groupMeans = [
    mean(awakeData);
    mean(fatigueData);
    mean(drowsyData)
];

groupStd = [
    std(awakeData);
    std(fatigueData);
    std(drowsyData)
];

allData = [
    awakeData(:);
    fatigueData(:);
    drowsyData(:)
];

grandMean = mean(allData);

%% -------- 组间平方和 SSB --------
SS_between = 0;
for i = 1:k
    currentData = groupData{i};
    ni = length(currentData);
    currentMean = mean(currentData);
    SS_between = SS_between + ni * (currentMean - grandMean)^2;
end

%% -------- 组内平方和 SSW --------
SS_within = 0;
for i = 1:k
    currentData = groupData{i};
    currentMean = mean(currentData);
    SS_within = SS_within + sum((currentData - currentMean).^2);
end

%% -------- 自由度 --------
df_between = k - 1;
df_within = N - k;

%% -------- 均方 --------
MS_between = SS_between / df_between;
MS_within = SS_within / df_within;

%% -------- F统计量 --------
if MS_within == 0
    if MS_between == 0
        F_value = 0;
        p_ANOVA = 1;
    else
        F_value = Inf;
        p_ANOVA = 0;
    end
else
    F_value = MS_between / MS_within;
    x = df_within / (df_within + df_between * F_value);
    p_ANOVA = betainc(x, df_within/2, df_between/2);
end

%% -------- 效应量Eta平方 --------
SS_total = SS_between + SS_within;
if SS_total == 0
    eta_squared = 0;
else
    eta_squared = SS_between / SS_total;
end

%% -------- 输出ANOVA结果 --------
fprintf('\n================ 单因素ANOVA结果 ================\n');
fprintf('清醒：样本数 = %d，均值 = %.6f，标准差 = %.6f\n', ...
    n1, groupMeans(1), groupStd(1));
fprintf('疲劳：样本数 = %d，均值 = %.6f，标准差 = %.6f\n', ...
    n2, groupMeans(2), groupStd(2));
fprintf('嗜睡：样本数 = %d，均值 = %.6f，标准差 = %.6f\n', ...
    n3, groupMeans(3), groupStd(3));

fprintf('\nANOVA统计量：\n');
fprintf('组间平方和 SSB = %.10f\n', SS_between);
fprintf('组内平方和 SSW = %.10f\n', SS_within);
fprintf('总平方和 SST = %.10f\n', SS_total);
fprintf('组间自由度 = %d\n', df_between);
fprintf('组内自由度 = %d\n', df_within);
fprintf('组间均方 = %.10f\n', MS_between);
fprintf('组内均方 = %.10f\n', MS_within);
fprintf('F值 = %.6f\n', F_value);
fprintf('p值 = %.10f\n', p_ANOVA);
fprintf('Eta平方 = %.6f\n', eta_squared);

if p_ANOVA < 0.001
    fprintf('结论：三种状态之间存在显著差异，p < 0.001。\n');
elseif p_ANOVA < 0.01
    fprintf('结论：三种状态之间存在显著差异，p < 0.01。\n');
elseif p_ANOVA < 0.05
    fprintf('结论：三种状态之间存在显著差异，p < 0.05。\n');
else
    fprintf('结论：三种状态之间差异不显著，p >= 0.05。\n');
end

%% ===================== 15. 保存分析结果 =====================

pANOVA = p_ANOVA;
F_ANOVA = F_value;

resultFile = fullfile(pwd, '谱熵统计结果.mat');

save(resultFile, ...
    'awakeEntropy', ...
    'fatigueEntropy', ...
    'drowsyEntropy', ...
    'groupMeans', ...
    'groupStd', ...
    'SS_between', ...
    'SS_within', ...
    'SS_total', ...
    'df_between', ...
    'df_within', ...
    'MS_between', ...
    'MS_within', ...
    'F_ANOVA', ...
    'pANOVA', ...
    'eta_squared');

fprintf('\n统计结果已保存至：\n%s\n', resultFile);


%% =========================================================
%                    局部函数部分
%% =========================================================

function epochs = loadEEGExcelFile( ...
    filePath, sheetName, hasHeader, ...
    expectedSamples, expectedEpochs)

    fprintf('\n正在读取：%s\n', filePath);

    if hasHeader
        rawData = readmatrix(filePath, ...
            'Sheet', sheetName, 'NumHeaderLines', 1);
    else
        rawData = readmatrix(filePath, 'Sheet', sheetName);
    end

    if isempty(rawData)
        error('Excel文件为空：%s', filePath);
    end

    [numRows, numColumns] = size(rawData);

    fprintf('实际读取尺寸：%d行 × %d列\n', numRows, numColumns);

    if numRows ~= expectedSamples || numColumns ~= expectedEpochs
        warning(['文件%s的尺寸不是预期的' ...
            '%d行×%d列，而是%d行×%d列。'], ...
            filePath, expectedSamples, expectedEpochs, ...
            numRows, numColumns);
    end

    epochs = cell(numColumns, 1);
    validCount = 0;

    for i = 1:numColumns
        signal = rawData(:, i);
        signal = signal(isfinite(signal));

        if isempty(signal)
            warning('第%d列没有有效数据，已跳过。', i);
            continue;
        end

        if length(signal) < 8
            warning('第%d列数据点太少，已跳过。', i);
            continue;
        end

        validCount = validCount + 1;
        epochs{validCount} = signal(:);
    end

    epochs = epochs(1:validCount);

    if isempty(epochs)
        error('文件中没有有效EEG分段：%s', filePath);
    end

    fprintf('有效EEG分段数：%d\n', length(epochs));
end


function epochsOut = preprocessEpochs(epochsIn)

    epochsOut = cell(size(epochsIn));

    for i = 1:length(epochsIn)
        x = epochsIn{i};
        x = x(:);
        x = x(isfinite(x));

        if isempty(x)
            epochsOut{i} = [];
            continue;
        end

        x = x - mean(x);
        epochsOut{i} = x;
    end

    validIndex = ~cellfun(@isempty, epochsOut);
    epochsOut = epochsOut(validIndex);
end


function [PSD, f, Hspec, relativePower] = ...
    calculateStateFeatures( ...
    epochs, fs, analysisBand, ...
    windowSeconds, overlapRatio, bands)

    numEpochs = length(epochs);

    firstSignal = epochs{1};
    firstSignal = firstSignal(:);

    windowLength = min(length(firstSignal), ...
        round(windowSeconds * fs));

    if windowLength < 8
        error('EEG分段长度太短，无法进行Welch分析。');
    end

    window = hamming(windowLength);
    overlapLength = floor(overlapRatio * windowLength);
    nfft = max(2^nextpow2(windowLength), windowLength);

    [Pfirst, ffirst] = pwelch(firstSignal, window, ...
        overlapLength, nfft, fs);

    freqIndex = ffirst >= analysisBand(1) & ...
                ffirst <= analysisBand(2);

    f = ffirst(freqIndex);
    numFreq = length(f);

    PSD = NaN(numEpochs, numFreq);
    Hspec = NaN(numEpochs, 1);
    relativePower = NaN(numEpochs, size(bands,1));

    for i = 1:numEpochs
        x = epochs{i};
        x = x(:);

        if length(x) < 8
            continue;
        end

        windowLength = min(length(x), round(windowSeconds * fs));
        window = hamming(windowLength);
        overlapLength = floor(overlapRatio * windowLength);
        nfft = max(2^nextpow2(windowLength), windowLength);

        [Pfull, ffull] = pwelch(x, window, ...
            overlapLength, nfft, fs);

        currentIndex = ffull >= analysisBand(1) & ...
                       ffull <= analysisBand(2);

        currentF = ffull(currentIndex);
        currentP = Pfull(currentIndex);

        if isempty(currentP), continue; end
        if sum(currentP) <= eps, continue; end
        if length(currentP) ~= numFreq, continue; end

        PSD(i,:) = currentP(:)';

        probability = currentP / sum(currentP);
        probability = probability + eps;
        probability = probability / sum(probability);
        K = length(probability);
        Hspec(i) = -sum(probability .* log(probability)) / log(K);

        totalPower = trapz(currentF, currentP);
        if totalPower <= eps, continue; end

        for b = 1:size(bands,1)
            bandIndex = currentF >= bands(b,1) & ...
                        currentF < bands(b,2);
            if sum(bandIndex) >= 2
                bandPower = trapz(currentF(bandIndex), ...
                                  currentP(bandIndex));
                relativePower(i,b) = bandPower / totalPower;
            end
        end
    end
end