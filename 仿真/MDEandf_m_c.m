clc
clear all

% wgnMDE_20 = [];

redMDE_20 = [];
for i = 1:1:20
%     wgndata=wgn(1,1000,1);
    reddata=rednoise(1000);
    d=1;
    m1=2;
    m2=3;
    c1=3;
    c2=6;
    c3=9;
    tau=1;
    scale=21;

%     wgnMDE1=MDE(wgndata,m1,c1,tau,scale);
%     wgnMDE2=MDE(wgndata,m1,c2,tau,scale);
%     wgnMDE3=MDE(wgndata,m1,c3,tau,scale);
%     wgnMDE4=MDE(wgndata,m2,c1,tau,scale);
%     wgnMDE5=MDE(wgndata,m2,c2,tau,scale);
%     wgnMDE6=MDE(wgndata,m2,c3,tau,scale);
%     wgnMDE1_20(i,:) = wgnMDE1;
%     wgnMDE2_20(i,:) = wgnMDE2;
%     wgnMDE3_20(i,:) = wgnMDE3;
%     wgnMDE4_20(i,:) = wgnMDE4;
%     wgnMDE5_20(i,:) = wgnMDE5;
%     wgnMDE6_20(i,:) = wgnMDE6;
   
    
    redMDE1=MDE(reddata,m1,c1,tau,scale);
    redMDE2=MDE(reddata,m1,c2,tau,scale);
    redMDE3=MDE(reddata,m1,c3,tau,scale);
    redMDE4=MDE(reddata,m2,c1,tau,scale);
    redMDE5=MDE(reddata,m2,c2,tau,scale);
    redMDE6=MDE(reddata,m2,c3,tau,scale);
    redMDE1_20(i,:) = redMDE1;
    redMDE2_20(i,:) = redMDE2;
    redMDE3_20(i,:) = redMDE3;
    redMDE4_20(i,:) = redMDE4;
    redMDE5_20(i,:) = redMDE5;
    redMDE6_20(i,:) = redMDE6;
    
    
end

redmuMDE1_20 = mean(redMDE1_20);
redstdMDE1_20 = std(redMDE1_20);

redmuMDE2_20 = mean(redMDE2_20);
redstdMDE2_20 = std(redMDE2_20);

redmuMDE3_20 = mean(redMDE3_20);
redstdMDE3_20 = std(redMDE3_20);

redmuMDE4_20 = mean(redMDE4_20);
redstdMDE4_20 = std(redMDE4_20);

redmuMDE5_20 = mean(redMDE5_20);
redstdMDE5_20 = std(redMDE5_20);

redmuMDE6_20 = mean(redMDE6_20);
redstdMDE6_20 = std(redMDE6_20);

% redmuMDE_30 = mean(redMDE_30);
% redstdMDE_30 = std(redMDE_30);

%%
x  = 1:1:length(redmuMDE1_20)-1;
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
errorbar(x, redmuMDE1_20(2:end), redstdMDE1_20(2:end), '-^', ...
    'Color', color1, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color1)          % 浅钢蓝
hold on
errorbar(x, redmuMDE2_20(2:end), redstdMDE2_20(2:end), '-o', ...
    'Color', color2, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color2)          % 深紫
errorbar(x, redmuMDE3_20(2:end), redstdMDE3_20(2:end), '-p', ...
    'Color', color3, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color3)          % 玫瑰粉
errorbar(x, redmuMDE4_20(2:end), redstdMDE4_20(2:end), '-^', ...
    'Color', color4, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color4)          % 青绿
errorbar(x, redmuMDE5_20(2:end), redstdMDE5_20(2:end), '-o', ...
    'Color', color5, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color5)          % 珊瑚橙
errorbar(x, redmuMDE6_20(2:end), redstdMDE6_20(2:end), '-p', ...
    'Color', color6, 'LineWidth', lineWidth, ...
    'MarkerSize', 10, 'MarkerFaceColor', color6)          % 橄榄绿

legend('m=2 c=3','m=2 c=6','m=2 c=9','m=3 c=3','m=3 c=6','m=3 c=9', ...
    'FontSize', fontSize, 'FontWeight', 'bold');

xlabel('Scale factor', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('MDE',          'FontSize', fontSize, 'FontWeight', 'bold');

set(gca, 'FontSize', fontSize, 'FontWeight', 'bold', 'LineWidth', axisWidth);
set(gca, 'Box', 'on', 'TickDir', 'in');
hold off