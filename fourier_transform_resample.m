% Song, Siyang, Shashank Jaiswal, Linlin Shen, and Michel Valstar
% Spectral Representation of Behaviour Primitives for Depression Analysis.
% IEEE Transactions on Affective Computing (2020)
% Email: siyang.song@nottingham.ac.uk
% input:
%--all_data: Multi-channel time-series facial behaviour primitives data
%--num_fre: sampling frequency
%--N: final used TOP-N frequencies
% output:
%--amp_map_return: amplitude spectrum map
%--phase_map_return: phase spectrum map

function [amp_map_return, phase_map_return,amp_map_b_filter_return,phase_map_b_filter_return,amp_map_no_filter_return,phase_map_no_filter_return,rnn_data,rnn_data_b] = fourier_transform_resample(all_data, N, num_fre)

[channel_num,length] = size(all_data);  % 获取数据维度
amp_map = zeros(channel_num,num_fre);   % 初始化幅值矩阵
phase_map = zeros(channel_num,num_fre); % 初始化相位矩阵
amp_map_b_filter = zeros(channel_num,num_fre);
phase_map_b_filter = zeros(channel_num,num_fre);
amp_map_no_filter = zeros(channel_num,num_fre);
phase_map_no_filter = zeros(channel_num,num_fre);
rnn_return = zeros(channel_num,num_fre);
rnn_b_return = zeros(channel_num,num_fre);

originalFs = 30;       % 原始采样率30Hz
targetFs = 15;         % 目标采样率（示例：降采样到15Hz）

% 设计自定义抗混叠滤波器（以FIR为例）
cutoff = targetFs/2;   % 物理截止频率（Nyquist频率）
transitionWidth = 1;   % 过渡带宽1Hz
attenuation = 80;      % 阻带衰减80dB

% 计算归一化频率参数
nyq = originalFs/2;
fc_normalized = cutoff / nyq;                 % 归一化截止频率
tw_normalized = transitionWidth / nyq;        % 归一化过渡带宽

% 使用凯撒窗设计滤波器
[n, beta] = kaiserord([fc_normalized, fc_normalized + tw_normalized], [1 0], [0.01 10^(-attenuation/20)]);
b = fir1(n, fc_normalized, 'low', kaiser(n+1, beta), 'noscale');

% 设计一个全通滤波器（无滤波效果）
b_allpass = 1; % 单系数全通滤波器

for i = 1:channel_num
    %对第i通道信号做FFT
    temp_contain = fft(all_data(i,:));
    % 取单边频谱（避免对称性冗余）
    if mod(length,2) == 0
        
        temp_contain = temp_contain(:,1:length/2+1);
    else
        
        temp_contain = temp_contain(:,1:(length+1)/2);
    end
    % 频域重采样（问题核心）
    temp_resample_data = resample(temp_contain,num_fre,size(temp_contain,2));
    temp_resample_data_b_filter = resample(temp_contain,num_fre,size(temp_contain,2),b);
    temp_resample_data_no_filter = resample(temp_contain,num_fre,size(temp_contain,2),b_allpass);

    amp_map(i,:) = abs(temp_resample_data)/length;  % 振幅
    phase_map(i,:) = angle(temp_resample_data); % 相位
    rnn_return(i,:) = temp_resample_data;

    amp_map_b_filter(i,:) = abs(temp_resample_data_b_filter)/length;  % 振幅
    phase_map_b_filter(i,:) = angle(temp_resample_data_b_filter); % 相位
    rnn_b_return(i,:) = temp_resample_data_b_filter;

    amp_map_no_filter(i,:) = abs(temp_resample_data_no_filter)/length;  % 振幅
    phase_map_no_filter(i,:) = angle(temp_resample_data_no_filter); % 相位

end
% 截取前N个频率成分
amp_map_return = amp_map(:,1:N);
phase_map_return = phase_map(:,1:N);

amp_map_b_filter_return = amp_map_b_filter(:,1:N);
phase_map_b_filter_return = phase_map_b_filter(:,1:N);

amp_map_no_filter_return = amp_map_no_filter(:,1:N);
phase_map_no_filter_return = phase_map_no_filter(:,1:N);

rnn_return_a = rnn_return(:,1:N);
rnn_data = real(ifft(rnn_return_a));

rnn_return_b = rnn_b_return(:,1:N);
rnn_data_b = real(ifft(rnn_return_b));

end

