%% 合并两张宏平均 ROC 的 .fig 文件
clc; clear; close all;

% ---------- 1. 文件路径 ----------
figPath_MDE   = 'C:\Users\Administrator\Desktop\C.M.T\TFMDE\三种分类系\MDE图像\宏平均（SVM）.fig';
figPath_TFMDE = 'C:\Users\Administrator\Desktop\C.M.T\TFMDE\三种分类系\TFMDE图像\宏平均(SVM）.fig';

% 文件存在性检查（括号全角/半角不一致时立刻报错）
if ~isfile(figPath_MDE)
    error('找不到 MDE 文件，请检查路径与括号是否为全角：%s', figPath_MDE);
end
if ~isfile(figPath_TFMDE)
    error('找不到 TFMDE 文件，请检查路径：%s', figPath_TFMDE);
end

% ---------- 2. 打开 fig 并提取曲线数据 ----------
[figMDE,   axMDE]   = getFigAndAxes(figPath_MDE);
[figTFMDE, axTFMDE] = getFigAndAxes(figPath_TFMDE);

[xMDE,   yMDE,   aucMDE]   = extractMainCurve(axMDE);
[xTFMDE, yTFMDE, aucTFMDE] = extractMainCurve(axTFMDE);

% ---------- 3. 新建合并图 ----------
figNew = figure('Position', [120 120 1000 900], 'Color', 'w', ...
    'Name', 'Macro-Average ROC (MDE & TFMDE)', 'NumberTitle', 'off');
hold on

% 对角线（Random）
plot([0 1], [0 1], '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 3.0);

% 两条宏平均 ROC 曲线
hMDE   = plot(xMDE,   yMDE,   '-', 'Color', [0.00 0.45 0.74], 'LineWidth', 4.5);  % 蓝
hTFMDE = plot(xTFMDE, yTFMDE, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 4.5);  % 橙红

% ---------- 4. 样式 ----------
grid on
set(gca, 'GridColor', [0.75 0.75 0.75], 'GridAlpha', 0.9, ...
    'GridLineStyle', '-', 'Layer', 'top');

box on
axis square
xlim([0 1]); ylim([0 1]);

set(gca, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 30, ...
    'FontWeight', 'bold', ...
    'LineWidth', 3, ...
    'Box', 'on', ...
    'TickDir', 'in', ...
    'XTick', 0:0.2:1, ...
    'YTick', 0:0.2:1);

xlabel('False Positive Rate', ...
    'FontSize', 30, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('True Positive Rate', ...
    'FontSize', 30, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

% ---------- 5. 图例（顺序：MDE → TFMDE） ----------
lgd = legend([hMDE hTFMDE], ...
    {sprintf('MDE   (AUC = %.4f)', aucMDE), ...
     sprintf('TFMDE (AUC = %.4f)', aucTFMDE)}, ...
    'Location', 'southeast', ...
    'FontName', 'Times New Roman', ...
    'FontSize', 20, ...
    'FontWeight', 'bold', ...
    'Box', 'on');
lgd.LineWidth = 2;

hold off

% 关闭原始 fig 窗口，避免叠在一起
close(figMDE); close(figTFMDE);

% 可选保存
% exportgraphics(figNew, 'MacroAveraged_ROC_MDE_TFMDE.png', 'Resolution', 300);


%% ==================== 工具函数 ====================
function [fig, ax] = getFigAndAxes(figPath)
    fig = openfig(figPath, 'invisible');
    axAll = findall(fig, 'Type', 'axes');
    if isempty(axAll)
        error('未在文件中找到坐标轴: %s', figPath);
    end
    areas = arrayfun(@(a) prod(a.Position(3:4)), axAll);
    [~, idx] = max(areas);
    ax = axAll(idx);
end

function [x, y, auc] = extractMainCurve(ax)
    % 从坐标轴中提取最长曲线（宏平均 ROC），并估算 AUC
    lines = findall(ax, 'Type', 'line');
    if isempty(lines)
        error('坐标轴中没有曲线');
    end
    nPts = arrayfun(@(l) numel(l.XData), lines);
    [~, idx] = max(nPts);       % 最长的那条
    L = lines(idx);

    x = L.XData(:);
    y = L.YData(:);

    % 确保 FPR 单调递增，便于积分
    [x, ia] = unique(x, 'stable');
    y = y(ia);
    y = max(0, min(1, y));

    % 曲线起点不是 (0,0) 时补一点
    if x(1) > 0
        x = [0; x];
        y = [0; y];
    end
    % 曲线终点不是 (1, ·) 时补一点
    if x(end) < 1
        x = [x; 1];
        y = [y; y(end)];
    end

    % 梯形积分估算 AUC
    auc = trapz(x, y);
end