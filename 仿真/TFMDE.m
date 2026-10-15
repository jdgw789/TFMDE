function Out_MDE = TFMDE(x, m, c, tau, Scale)
% 时-频联合多尺度分散熵（去除自适应映射）
% 输入：x - 原始信号, m,c,tau - 分散熵参数, Scale - 最大尺度
% 输出：1×Scale 的联合熵

    Out_MDE = NaN * ones(1, Scale);
    
    % ---------- 尺度 1（原始序列） ----------
    H_time1 = DisEn_NCDF(x, m, c, tau);
    H_spec1 = SpecEn(x);
    Out_MDE(1) = H_time1 * H_spec1;
    
    % ---------- 尺度 2~Scale ----------
    for j = 2:Scale
        xs = Multi(x, j);                        % 粗粒化序列
        
        % --- 时域分散熵（标准NCDF映射） ---
        H_time = DisEn_NCDF(xs, m, c, tau);
        
        % --- 频域谱熵 ---
        H_spec = SpecEn(xs);
        
        % --- 乘性融合 ---
        Out_MDE(j) = H_time * H_spec;
    end
end

% ===== 频域谱熵 =====
function H_spec = SpecEn(ts)
    N = length(ts);
    if N < 8
        H_spec = 0;          % 序列过短，返回0（融合后该项为0）
        return;
    end
    xd = detrend(ts);
    Y = fft(xd);
    Pyy = abs(Y(2:floor(N/2)+1)).^2;   % 单边功率谱（不含直流）
    ps = Pyy / sum(Pyy);
    ps(ps < eps) = [];
    H_spec = -sum(ps .* log(ps));      % 未归一化，保持动态范围
end

% ===== 粗粒化函数 =====
function M_Data = Multi(Data, S)
    L = length(Data);
    J = fix(L/S);
    M_Data = zeros(1, J);
    for i = 1:J
        M_Data(i) = mean(Data((i-1)*S+1 : i*S));
    end
end