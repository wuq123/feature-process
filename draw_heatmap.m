function [combined_image] = draw_heatmap(amp,phase)

% 数据归一化
amp_normalized = mat2gray(amp); % 振幅归一化到[0,1]
phase_normalized = (phase + pi) / (2*pi); % 相位归一化到[0,1]
%phase_normalized =  mat2gray(phase); % 相位归一化到[0,1]
% 合并为双通道RGB图像（红色=振幅，绿色=相位，蓝色=0）
combined_image = cat(3, amp_normalized, phase_normalized);

% 可视化
%figure;
%imshow(combined_image, 'InitialMagnification', 'fit');
%axis on; % 显示坐标轴
%xticks(0:10:size(amp,2)); % 设置频率刻度
%yticks(0:5:size(amp,1)); % 设置行为刻度
%xlabel('Frequency Index');
%ylabel('Behavior Index');
%title('Two-Channel Spectral Heatmap: Amplitude (Red) & Phase (Green)');

