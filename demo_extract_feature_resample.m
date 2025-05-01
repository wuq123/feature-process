% Song, Siyang, Shashank Jaiswal, Linlin Shen, and Michel Valstar
% Spectral Representation of Behaviour Primitives for Depression Analysis.
% IEEE Transactions on Affective Computing (2020)
% Email: siyang.song@nottingham.ac.uk

clear all;clc

%% setting

Primitive_num = 29; % the number of behaviour signals

N = 80; % Choosing TOP-N frequency (N < fre_resolution/2)

fre_resolution = 256; % sampling frequency 

%file_name = 'Freeform/332_4_Freeform_video.mat';

folder_path = 'E:\毕设\Feature processing\Human-behaviour-based-depression-analysis-using-hand-crafted-statistics-and-deep-learned-master\test';

files_list = dir(fullfile(folder_path,'*.mat'));

%% pre_processing

t_length = N*Primitive_num; % set feature length for amp/phase map 定义特征向量的总长度为 80×29=2320。


num_files = numel(files_list); % 获取文件夹中符合要求的文件个数
for i = 1:num_files         
    filename = files_list(i).name; % 获取文件名
    filepath = fullfile(files_list(i).folder, filename); % 获取文件路径
    
    raw_data = load(filepath); % load data
    % 在这里编写处理读取的文件内容的代码
    raw_data = raw_data.matrixData;

    processed_data = preprocess(raw_data); % substracting median values, ypu can customized your own preprocess method here
    
    %processed_data = processed_data';     %矩阵转置
    
    %% feature extraction
    
    sta_fea = getVideoFeature(processed_data); % compute statistics features
    % 频域特征生成
    [amp_map, phase_map,amp_map_b_filter,phase_map_b_filter,amp_map_no_filter,phase_map_no_filter,rnn_data,rnn_data_b] = fourier_transform_resample(processed_data, N,fre_resolution);% 2-D amplitude map and phase map generation
    %频谱热图组成
    [resultimage] = draw_heatmap(amp_map,phase_map);
    [b_filter] =  draw_heatmap(amp_map_b_filter,phase_map_b_filter);
    [no_filter] = draw_heatmap(amp_map_no_filter,phase_map_no_filter);
    save(filepath,'resultimage','b_filter','no_filter','rnn_data','rnn_data_b','-v7.3');
    %一维特征展平
    amp_flat_data = flat_data(amp_map,t_length, N);% 1-D amplitude feature generation
    phase_flat_data = flat_data(phase_map,t_length, N);% 1-D phase feature generation

    amp_flat_data_b_filter = flat_data(amp_map_b_filter,t_length, N);% 
    phase_flat_data_b_filter = flat_data(phase_map_b_filter,t_length, N);%

    amp_flat_data_no_filter = flat_data(amp_map_no_filter,t_length, N);% 
    phase_flat_data_no_filter = flat_data(phase_map_no_filter,t_length, N);%

    rnn_flat_data = flat_data(rnn_data,t_length, N);

    rnn_b_flat_data = flat_data(rnn_data_b,t_length, N);
end





