clf('reset');
close all;

BASE = '/Users/cng/Documents/ENPH352/2-waterwaves/cleandata/';
LIST = dir(fullfile(BASE, '*.mat'));
NAMES = {LIST.name};
SAMPLE_NUM = 65536/4; SAMPLE_RATE = 65536/4/10; %BBD.m

temp = load(fullfile(BASE, NAMES{1}));
[ft_1, ft_2] = size(temp.ft);
[data_1, data_2] = size(temp.data);
[time_1, time_2] = size(temp.time);

ft_big = zeros(ft_1, ft_2, numel(NAMES));
data_big = zeros(data_1, data_2, numel(NAMES));
time_big = zeros(time_1, time_2, numel(NAMES));

freq = linspace(0, SAMPLE_RATE, SAMPLE_NUM);
freqf = @(x) (x-1) * SAMPLE_RATE/SAMPLE_NUM;

depths = [1, 2, 3.7, 5, 6.5, 8, 9, 10, 11.2, 12.5]; % cm

%%% begin computing theoretical freqs
% Symbolic reps 
syms h k w f wk dwdk dwdh; g = 9.81;
HF=0.9384; KF=1/1.1466;
w(h,k) = sqrt(g*k/KF * tanh(k*h*HF/KF)); f(h,k) = w(h,k) / (2*pi);
w_v(h,k) = sqrt(g*k * tanh(k*h));
wk(h,k) = w(h,k)/k;
dwdk = diff(w,k); dwdh = diff(w,h);

% Convert to function handles
omega_v = matlabFunction(w_v(h,k));
omega = matlabFunction(w(h,k));
phase = matlabFunction(wk(h,k));
group = matlabFunction(dwdk(h,k));

%%% end compjting theoretical freqs


for i = 1:numel(NAMES) 
   temp = load(fullfile(BASE, NAMES{i}));
   ft_big(:,:,i) = temp.ft;
   data_big(:,:,i) = temp.data;
   time_big(:,:,i) = temp.time;
end

PLOTS = numel(NAMES)/3;

figure;
for i = 1:PLOTS
    % MAGIC NUMBERS
    col = 2; row = ceil(PLOTS/col); 
    ax = subplot(row,col, i);
    hold on;
    for j = 1:3
        plot(ax, freq', ft_big(:,1,(i-1) * 3 + j));
    end
    
    xlim([freq(2) freq(100)])
    xlabel("freq (Hz)")
    %legend('1','2','3','4','5');
    title(num2str(depths(i)) + " \pm 0.1 cm depth");
end

peaks_big = cell(1,PLOTS); locs_big = cell(1,PLOTS);

figure;
for i = 1:PLOTS
    % MAGIC NUMBERS
    col = 2; row = ceil(PLOTS/col); threshold = 4;
    ax = subplot(row,col, i);
    hold on;
    y = ft_big(:,1,(i-1)*3 + 1) / 3;
    y = y + ft_big(:,1,(i-1)*3 + 2) / 3;
    y = y + ft_big(:,1,(i-1)*3 + 3) / 3;
    
    [peaks, locs, w, p] = findpeaks(y); idx = find(p > threshold);
    peaks = peaks(idx); locs = locs(idx);
    peaks_big{i} = peaks; locs_big{i} = locs;
    
    plot(ax, freq', y);
    scatter(ax, freq(locs), peaks);
    xlim([freq(2) freq(100)]);
    
    xlabel("freq (Hz)")
    %legend('1','2','3','4','5');
    title("Averaged: " + num2str(depths(i)) + " \pm 0.1 cm depth");
end

figure; hold on;
title("Frequency of observed modes vs depth");
for i = 1:PLOTS
    locs = locs_big{i}; freqs = freq(locs);
    depth = ones(size(locs)) * depths(i);
    scatter(depth, freqs, '*');
end

% constants:
L = 50/100;
depth_vec = linspace(depths(2), depths(end), 100);

fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0],...
               'Upper',[Inf,Inf],...
               'StartPoint',[1 1]);
ft = fittype('1/2/pi*(9.81*n*pi/0.5/a * tanh(n*pi/0.5*x/100*b/a))^0.5','problem','n','options',fo);

a = zeros(1,8);b=a;da=a;db=a;

for n = 1:8
    if n == 2 || n== 6
             ki = n * pi / L;
       h = zeros(1,2);
    %h(1) = plot(depth_vec, omega_v(depth_vec./100, ki)./2./pi, 'k:', 'DisplayName','Theoretical values');
    %h(2) = plot(depth_vec, omega(depth_vec./100, ki)./2./pi, 'r--', 'DisplayName','Adjusted values');
    continue
    end
    y = freqf(fit_vals(n,:));
    [curve2,gof2] = fit(depths(2:end)',y',ft,'problem',n);
    
    %plot(curve2,'k--');
     ki = n * pi / L;
    h = zeros(1,2);
    %h(1) = plot(depth_vec, omega_v(depth_vec./100, ki)./2./pi, 'k:', 'DisplayName','Theoretical values');
    %h(2) = plot(depth_vec, omega(depth_vec./100, ki)./2./pi, 'r--', 'DisplayName','Adjusted values');
    coeff = coeffvalues(curve2); conf = confint(curve2);
    a(n) = coeff(1); b(n) = coeff(2);
    da(n) = 0.5*(conf(2,1) - conf(1,1));
    db(n) = 0.5*(conf(2,2) - conf(1,2));
    
    ylim([0,10]);
    xlabel('Depth (cm)'); ylabel('Frequency (Hz)');
end
% Weighted average of final a, final b

a=nonzeros(a);b=nonzeros(b);da=nonzeros(da);db=nonzeros(db);
wa = 1./(da.^2);wb = 1./(db.^2);
KF = sum(a.*wa ./ sum(wa)); da_av = sqrt(sum( (da.*wa./sum(wa)).^2 ));
HF = sum(b.*wb ./ sum(wb)); db_av = sqrt(sum( (db.*wb./sum(wb)).^2 ));

disp([KF da_av]);
disp([HF db_av]);
hold off;

% Plot the phase velocities for the given depths
figure; hold on;

for i = 1:numel(depths)
    k = (1:10) * pi / L;
    phase_vels = phase(depths(i)/100, k);
    plot(depths(i), phase_vels, 'k.');
end

xlabel('Depth (cm)'); ylabel('Phase velocity (m/s)');
% Plot the group velocities for the given depths.
figure; hold on;

for i = 1:numel(depths)
    k = (1:10) * pi / L;
    phase_vels = group(depths(i)/100, k);
    plot(depths(i), phase_vels, 'k.');
end

xlabel('Depth (cm)'); ylabel('Group velocity (m/s)');
