%% ==================== 雷达图（MDE vs TFMDE 三张独立图） ====================
clc; clear; close all;

%% ---------- 1. 数据准备 ----------
% 每行：[Macro/Weighted avg, Awake, Fatigue, Drowsy]
P_MDE   = [0.9203, 0.8246, 0.9362, 1.0000];
R_MDE   = [0.9133, 0.9400, 0.8800, 0.9200];
F1_MDE  = [0.9147, 0.8785, 0.9073, 0.9583];

P_TFMDE  = [0.9738, 0.9792, 0.9423, 1.0000];
R_TFMDE  = [0.9733, 0.9400, 0.9800, 1.0000];
F1_TFMDE = [0.9733, 0.9592, 0.9608, 1.0000];

% 轴标签（四个维度）
axLabels = {'Macro', 'Awake', 'Fatigue', 'Drowsy'};

% 曲线名称与配色
lineNames  = {'MDE', 'TFMDE'};
lineColors = [
    0.20 0.45 0.85;   % MDE  蓝
    0.85 0.20 0.20    % TFMDE 红
];
% 线型：MDE用虚线，TFMDE用实线
lineStyles = {'--', '-'};

% ================= 核心参数设定 =================
fontSize  = 27;      % 字体大小
lineWidth = 4.0;     % 曲线线宽
axisWidth = 3;
markerSz  = 12;      % 标记点大小

%% ---------- 2. 绘图：三张独立的图 ----------
% 准备数据
dataP  = [P_MDE;  P_TFMDE];
dataR  = [R_MDE;  R_TFMDE];
dataF1 = [F1_MDE; F1_TFMDE];

% ---- 图1：Precision（只传 (a) 作为标号） ----
fig1 = figure('Color', 'w', 'Position', [100 100 900 900], ...
    'Name', 'Radar - Precision', 'NumberTitle', 'off');
drawRadar(dataP, axLabels, lineNames, lineColors, lineStyles, ...
    fontSize, axisWidth, lineWidth, markerSz, '(a)');
% exportgraphics(fig1, 'Radar_Precision.png', 'Resolution', 300);

% ---- 图2：Recall（只传 (b) 作为标号） ----
fig2 = figure('Color', 'w', 'Position', [200 200 900 900], ...
    'Name', 'Radar - Recall', 'NumberTitle', 'off');
drawRadar(dataR, axLabels, lineNames, lineColors, lineStyles, ...
    fontSize, axisWidth, lineWidth, markerSz, '(b)');
% exportgraphics(fig2, 'Radar_Recall.png', 'Resolution', 300);

% ---- 图3：F1-Score（只传 (c) 作为标号） ----
fig3 = figure('Color', 'w', 'Position', [300 300 900 900], ...
    'Name', 'Radar - F1-Score', 'NumberTitle', 'off');
drawRadar(dataF1, axLabels, lineNames, lineColors, lineStyles, ...
    fontSize, axisWidth, lineWidth, markerSz, '(c)');
% exportgraphics(fig3, 'Radar_F1Score.png', 'Resolution', 300);


%% ==================== 辅助函数 ====================
function drawRadar(data, axLabels, lineNames, lineColors, lineStyles, ...
                   fontSize, axisWidth, lineWidth, markerSz, ttl)
% data: 2 × nAxis，第1行MDE，第2行TFMDE

    nLines = size(data, 1);
    nAxis  = size(data, 2);

    % 量程（截断坐标轴，放大两者在90%以上高分段的差异）
    rMin = 0.80;
    rMax = 1.00;

    % 归一化到 [0, 1]
    dataN = (data - rMin) / (rMax - rMin);
    dataN = max(0, min(1, dataN));

    % 每个轴的角度（弧度，从顶部起顺时针）
    theta = (0:nAxis-1) * 2*pi / nAxis;
    xDir  = sin(theta);
    yDir  = cos(theta);

    % 创建笛卡尔坐标轴
    ax = gca;
    hold(ax, 'on');
    axis(ax, 'equal');
    axis(ax, 'off');
    
    % 【修改点】：扩大下方坐标轴范围，防止底部文字被截断
    xlim(ax, [-1.7, 1.7]);
    ylim(ax, [-1.8, 1.7]); 

    % ---------- 同心圆网格 ----------
    rTicks = rMin:0.02:rMax;
    rTickN = (rTicks - rMin) / (rMax - rMin);
    thCircle = linspace(0, 2*pi, 300);
    for ri = 1:numel(rTickN)
        plot(ax, rTickN(ri)*cos(thCircle), rTickN(ri)*sin(thCircle), ...
            '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2);
    end

    % ---------- 射线轴 ----------
    for a = 1:nAxis
        plot(ax, [0, xDir(a)], [0, yDir(a)], ...
            '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2);
    end

    % ---------- 径向刻度标签 ----------
    for i = 1:numel(rTicks)
        text(ax, 0.03, rTickN(i), sprintf('%.2f', rTicks(i)), ...
            'FontName', 'Times New Roman', ...
            'FontSize', fontSize-10, 'FontWeight', 'bold', ...
            'Color', [0.4 0.4 0.4]);
    end

    % ---------- 半透明填充 + 曲线 ----------
    h = gobjects(nLines, 1);
    for m = 1:nLines
        rVals  = dataN(m, :);
        xPoly  = rVals .* xDir;
        yPoly  = rVals .* yDir;
        xPatch = [xPoly, xPoly(1)];      % 闭合
        yPatch = [yPoly, yPoly(1)];

        % 半透明纯色填充
        patch(ax, 'XData', xPatch, 'YData', yPatch, ...
            'FaceColor', lineColors(m, :), ...
            'FaceAlpha', 0.10, ...
            'EdgeColor', 'none');

        % 曲线 + 标记
        h(m) = plot(ax, xPatch, yPatch, lineStyles{m}, ...
            'Color', lineColors(m, :), ...
            'LineWidth', lineWidth, ...
            'Marker', 'o', ...
            'MarkerSize', markerSz, ...
            'MarkerFaceColor', lineColors(m, :), ...
            'MarkerEdgeColor', 'w');
    end

    % ---------- 轴标签 ----------
    labelR = 1.25;
    for a = 1:nAxis
        text(ax, xDir(a)*labelR, yDir(a)*labelR, axLabels{a}, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontName', 'Times New Roman', ...
            'FontSize', fontSize, ... 
            'FontWeight', 'bold', ...
            'Color', [0.1 0.1 0.1]);
    end

    % ---------- 每个轴外侧数值标注 ----------
    valR = 1.55;
    for a = 1:nAxis
        txtLines = cell(nLines, 1);
        for m = 1:nLines
            txtLines{m} = sprintf('%s:%.4f', lineNames{m}, data(m, a));
        end
        text(ax, xDir(a)*valR, yDir(a)*valR, strjoin(txtLines, newline), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontName', 'Times New Roman', ...
            'FontSize', fontSize-8, ... 
            'FontWeight', 'bold', ...
            'Color', [0.1 0.1 0.1]);
    end

    % ---------- 【修改点】：删除原顶部title，在底部添加标号 ----------
    % 原来的 title(ax, ttl, ...) 已移除
    % 将abc标号放在图的下方（Y轴坐标为负，靠近下边缘）
    text(ax, 0, -1.75, ttl, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'FontName', 'Times New Roman', ...
        'FontSize', fontSize+2, ...
        'FontWeight', 'bold', ...
        'Color', 'k');

    % ---------- 图例 ----------
    lgd = legend(ax, h, lineNames, ...
        'Location', 'southoutside', ... % 图例放下方，abc标号会位于图例上方，视觉上更合理
        'Orientation', 'horizontal', ...
        'FontName', 'Times New Roman', ...
        'FontSize', fontSize-4, ... 
        'FontWeight', 'bold', ...
        'Box', 'on');
    lgd.LineWidth = 1.5;
    
    hold(ax, 'off');
end