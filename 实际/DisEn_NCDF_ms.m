function [Out_DisEn, npdf] = DisEn_NCDF_ms(x, m, nc, mu, sigma, tau)
%
% This function calculates dispersion entropy (DisEn) using normal cumulative
% distribution function (NCDF) with defined mean (mu) and standard deviation (sigma).
% This version does NOT require the Statistics and Machine Learning Toolbox.
%
% Inputs:
%   x    : univariate signal - a vector of size 1 x N
%   m    : embedding dimension
%   nc   : number of classes (usually between 3 and 9)
%   mu   : mean of the normal distribution for NCDF mapping
%   sigma: standard deviation of the normal distribution for NCDF mapping
%   tau  : time lag (usually 1)
%
% Outputs:
%   Out_DisEn : scalar - dispersion entropy of x
%   npdf      : normalized number of dispersion patterns (length nc^m)
%
% Reference:
% [1] H. Azami, M. Rostaghi, D. Abasolo, and J. Escudero, "Refined Composite
%     Multiscale Dispersion Entropy and its Application to Biomedical Signals",
%     IEEE Trans. Biomed. Eng., 2017.
% [2] M. Rostaghi and H. Azami, "Dispersion Entropy: A Measure for Time-Series
%     Analysis", IEEE Signal Process. Lett., vol. 23, n. 5, pp. 610-614, 2016.
%
% If you use the code, please cite references [1] and [2].
%
% Original authors: Hamed Azami, Mostafa Rostaghi, Javier Escudero Rodriguez
% Toolbox-free adaptation: (your name/date if you wish)
%

N = length(x);

% --- Normal CDF via erf (no toolbox required) ---
y = 0.5 * (1 + erf((x - mu) / (sigma * sqrt(2))));

% --- Clipping to avoid exact 0 or 1 (same as original) ---
for i_N = 1:N
    if y(i_N) == 1
        y(i_N) = 1 - 1e-10;
    end
    if y(i_N) == 0
        y(i_N) = 1e-10;
    end
end

% --- Map to integer classes 1..nc ---
z = round(y * nc + 0.5);

% --- Generate all possible dispersion patterns (keys) ---
all_patterns = (1:nc)';
for f = 2:m
    temp = all_patterns;
    all_patterns = [];
    j = 1;
    for w = 1:nc
        [a, b] = size(temp); %#ok<ASGLU>
        all_patterns(j:j+a-1, :) = [temp, w * ones(a, 1)];
        j = j + a;
    end
end

key = zeros(1, nc^m);
for i = 1:nc^m
    for ii = 1:m
        key(i) = key(i)*10 + all_patterns(i, ii);
    end
end

% --- Time-delay embedding and conversion to keys ---
embd2 = zeros(N - (m-1)*tau, 1);
for i = 1:m
    embd2 = z(1+(i-1)*tau : N-(m-i)*tau)' * 10^(m-i) + embd2;
end

% --- Count occurrences of each pattern ---
pdf = zeros(1, nc^m);
for id = 1:nc^m
    [R, ~] = find(embd2 == key(id));
    pdf(id) = length(R);
end

npdf = pdf / (N - (m-1)*tau);
p = npdf(npdf ~= 0);
Out_DisEn = -sum(p .* log(p));