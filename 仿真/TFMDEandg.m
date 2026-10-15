clc
clear all

wgnTFMDE_20 = [];
% wgnTFMDE2_20 = [];
% wgnTFMDE3_20 = [];
% wgnTFMDE4_20 = [];
% wgnTFMDE5_20 = [];
% wgnTFMDE6_20 = [];
% redTFMDE_20 = [];
for i = 1:1:20
    wgndata=wgn(1,1000,1);
%     reddata=rednoise(1000);
    d=1;
    m1=2;
    m2=3;
    c1=3;
    c2=6;
    c3=9;
    tau=1;
    scale=21;

    wgnTFMDE1=TFMDE(wgndata,m1,c1,tau,scale);
    wgnTFMDE2=TFMDE(wgndata,m1,c2,tau,scale);
    wgnTFMDE3=TFMDE(wgndata,m1,c3,tau,scale);
    wgnTFMDE4=TFMDE(wgndata,m2,c1,tau,scale);
    wgnTFMDE5=TFMDE(wgndata,m2,c2,tau,scale);
    wgnTFMDE6=TFMDE(wgndata,m2,c3,tau,scale);
    wgnTFMDE1_20(i,:) = wgnTFMDE1;
    wgnTFMDE2_20(i,:) = wgnTFMDE2;
    wgnTFMDE3_20(i,:) = wgnTFMDE3;
    wgnTFMDE4_20(i,:) = wgnTFMDE4;
    wgnTFMDE5_20(i,:) = wgnTFMDE5;
    wgnTFMDE6_20(i,:) = wgnTFMDE6;
   
    
%     redTFMDE=TFMDE(reddata,m,c,tau,scale);
%     redTFMDE_30(i,:) = redTFMDE;
    
    
end

wgnmuTFMDE1_20 = mean(wgnTFMDE1_20);
wgnstdTFMDE1_20 = std(wgnTFMDE1_20);

wgnmuTFMDE2_20 = mean(wgnTFMDE2_20);
wgnstdTFMDE2_20 = std(wgnTFMDE2_20);

wgnmuTFMDE3_20 = mean(wgnTFMDE3_20);
wgnstdTFMDE3_20 = std(wgnTFMDE3_20);

wgnmuTFMDE4_20 = mean(wgnTFMDE4_20);
wgnstdTFMDE4_20 = std(wgnTFMDE4_20);

wgnmuTFMDE5_20 = mean(wgnTFMDE5_20);
wgnstdTFMDE5_20 = std(wgnTFMDE5_20);

wgnmuTFMDE6_20 = mean(wgnTFMDE6_20);
wgnstdTFMDE6_20 = std(wgnTFMDE6_20);

% redmuTFMDE_30 = mean(redTFMDE_30);
% redstdTFMDE_30 = std(redTFMDE_30);

%%TFMDE
x1 = 1:1:length(wgnmuTFMDE1_20)-1;
% x2  = 1:1:length(wgnmuTFMDE2_20)-1
% x3  = 1:1:length(wgnmuTFMDE3_20)-1
% x4  = 1:1:length(wgnmuTFMDE4_20)-1
% x5  = 1:1:length(wgnmuTFMDE5_20)-1
% x6  = 1:1:length(wgnmuTFMDE6_20)-1

% 参考图风格配色（柔和、区分度足够）
color1 = [0.42 0.62 0.82];   % 浅钢蓝
color2 = [0.38 0.32 0.58];   % 深紫
color3 = [0.90 0.58 0.72];   % 玫瑰粉
color4 = [0.35 0.70 0.65];   % 青绿
color5 = [0.90 0.55 0.30];   % 珊瑚橙
color6 = [0.55 0.70 0.35];   % 橄榄绿

% 统一格式参数
fontSize  = 30;
lineWidth = 4.5;
axisWidth = 3;

figure(1)
errorbar(x1, wgnmuTFMDE1_20(2:end), wgnstdTFMDE1_20(2:end), '-^', ...
    'Color', color1, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color1)          % 浅钢蓝
hold on
errorbar(x1, wgnmuTFMDE2_20(2:end), wgnstdTFMDE2_20(2:end), '-o', ...
    'Color', color2, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color2)          % 深紫
errorbar(x1, wgnmuTFMDE3_20(2:end), wgnstdTFMDE3_20(2:end), '-p', ...
    'Color', color3, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color3)          % 玫瑰粉
errorbar(x1, wgnmuTFMDE4_20(2:end), wgnstdTFMDE4_20(2:end), '-^', ...
    'Color', color4, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color4)          % 青绿
errorbar(x1, wgnmuTFMDE5_20(2:end), wgnstdTFMDE5_20(2:end), '-o', ...
    'Color', color5, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color5)          % 珊瑚橙
errorbar(x1, wgnmuTFMDE6_20(2:end), wgnstdTFMDE6_20(2:end), '-p', ...
    'Color', color6, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color6)          % 橄榄绿
% errorbar(x,redmuTFMDE_20(2:end),redstdTFMDE_20(2:end),'-or','LineWidth',1','MarkerSize',8)

legend('m=2 c=3','m=2 c=6','m=2 c=9','m=3 c=3','m=3 c=6','m=3 c=9', ...
    'FontSize', fontSize, 'FontWeight', 'bold');

xlabel('Scale factor', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('TFMDE',        'FontSize', fontSize, 'FontWeight', 'bold');

set(gca, 'FontSize', fontSize, 'FontWeight', 'bold', 'LineWidth', axisWidth);
set(gca, 'Box', 'on', 'TickDir', 'in');
hold off