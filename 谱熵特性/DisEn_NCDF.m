function [Out_DisEn, npdf] = DisEn_NCDF(x, m, nc, tau)
% 原始 DisEn_NCDF 的无工具箱版本
% 用 erfc 替换 normcdf，其余逻辑完全不变

N = length(x);

sigma_x = std(x);
mu_x = mean(x);

% ---- 替代 normcdf(x, mu_x, sigma_x) ----
% 标准正态累积分布函数：Φ(z) = 0.5 * erfc(-z / sqrt(2))
z_scaled = (x - mu_x) ./ sigma_x;
y = 0.5 * erfc(-z_scaled / sqrt(2));
% ----------------------------------------

% 边界处理（保持与原文完全一致）
for i_N = 1:N
    if y(i_N) == 1
        y(i_N) = 1 - 1e-10;
    end
    if y(i_N) == 0
        y(i_N) = 1e-10;
    end
end

% 映射到 1..nc 的整数类别
z = round(y * nc + 0.5);

% 以下代码与原函数完全相同
all_patterns = (1:nc)';

for f = 2:m
    temp = all_patterns;
    all_patterns = [];
    j = 1;
    for w = 1:nc
        [a, b] = size(temp);
        all_patterns(j:j+a-1, :) = [temp, w * ones(a, 1)];
        j = j + a;
    end
end

for i = 1:nc^m
    key(i) = 0;
    for ii = 1:m
        key(i) = key(i) * 10 + all_patterns(i, ii);
    end
end

embd2 = zeros(N - (m-1)*tau, 1);
for i = 1:m
    embd2 = [z(1+(i-1)*tau : N-(m-i)*tau)]' * 10^(m-i) + embd2;
end

pdf = zeros(1, nc^m);
for id = 1:nc^m
    [R, C] = find(embd2 == key(id));
    pdf(id) = length(R);
end

npdf = pdf / (N - (m-1)*tau);
p = npdf(npdf ~= 0);
Out_DisEn = -sum(p .* log(p));
end