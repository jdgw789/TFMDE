clc
clear all

wgnMDE_20 = [];
% wgnMDE2_20 = [];
% wgnMDE3_20 = [];
% wgnMDE4_20 = [];
% wgnMDE5_20 = [];
% wgnMDE6_20 = [];
% redMDE_20 = [];
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

    wgnMDE1=MDE(wgndata,m1,c1,tau,scale);
    wgnMDE2=MDE(wgndata,m1,c2,tau,scale);
    wgnMDE3=MDE(wgndata,m1,c3,tau,scale);
    wgnMDE4=MDE(wgndata,m2,c1,tau,scale);
    wgnMDE5=MDE(wgndata,m2,c2,tau,scale);
    wgnMDE6=MDE(wgndata,m2,c3,tau,scale);
    wgnMDE1_20(i,:) = wgnMDE1;
    wgnMDE2_20(i,:) = wgnMDE2;
    wgnMDE3_20(i,:) = wgnMDE3;
    wgnMDE4_20(i,:) = wgnMDE4;
    wgnMDE5_20(i,:) = wgnMDE5;
    wgnMDE6_20(i,:) = wgnMDE6;
   
    
%     redMDE=MDE(reddata,m,c,tau,scale);
%     redMDE_30(i,:) = redMDE;
    
    
end

wgnmuMDE1_20 = mean(wgnMDE1_20);
wgnstdMDE1_20 = std(wgnMDE1_20);

wgnmuMDE2_20 = mean(wgnMDE2_20);
wgnstdMDE2_20 = std(wgnMDE2_20);

wgnmuMDE3_20 = mean(wgnMDE3_20);
wgnstdMDE3_20 = std(wgnMDE3_20);

wgnmuMDE4_20 = mean(wgnMDE4_20);
wgnstdMDE4_20 = std(wgnMDE4_20);

wgnmuMDE5_20 = mean(wgnMDE5_20);
wgnstdMDE5_20 = std(wgnMDE5_20);

wgnmuMDE6_20 = mean(wgnMDE6_20);
wgnstdMDE6_20 = std(wgnMDE6_20);

% redmuMDE_30 = mean(redMDE_30);
% redstdMDE_30 = std(redMDE_30);

%%
x1 = 1:1:length(wgnmuMDE1_20)-1;
% x2  = 1:1:length(wgnmuMDE2_20)-1
% x3  = 1:1:length(wgnmuMDE3_20)-1
% x4  = 1:1:length(wgnmuMDE4_20)-1
% x5  = 1:1:length(wgnmuMDE5_20)-1
% x6  = 1:1:length(wgnmuMDE6_20)-1

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
errorbar(x1, wgnmuMDE1_20(2:end), wgnstdMDE1_20(2:end), '-^', ...
    'Color', color1, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color1)          % 浅钢蓝
hold on
errorbar(x1, wgnmuMDE2_20(2:end), wgnstdMDE2_20(2:end), '-o', ...
    'Color', color2, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color2)          % 深紫
errorbar(x1, wgnmuMDE3_20(2:end), wgnstdMDE3_20(2:end), '-p', ...
    'Color', color3, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color3)          % 玫瑰粉
errorbar(x1, wgnmuMDE4_20(2:end), wgnstdMDE4_20(2:end), '-^', ...
    'Color', color4, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color4)          % 青绿
errorbar(x1, wgnmuMDE5_20(2:end), wgnstdMDE5_20(2:end), '-o', ...
    'Color', color5, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color5)          % 珊瑚橙
errorbar(x1, wgnmuMDE6_20(2:end), wgnstdMDE6_20(2:end), '-p', ...
    'Color', color6, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color6)          % 橄榄绿

legend('m=2 c=3','m=2 c=6','m=2 c=9','m=3 c=3','m=3 c=6','m=3 c=9', ...
    'FontSize', fontSize, 'FontWeight', 'bold');

xlabel('Scale factor', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('MDE',          'FontSize', fontSize, 'FontWeight', 'bold');

set(gca, 'FontSize', fontSize, 'FontWeight', 'bold', 'LineWidth', axisWidth);
set(gca, 'Box', 'on', 'TickDir', 'in');
hold off