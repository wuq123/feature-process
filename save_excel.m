data = load('phase.mat');  % 加载MAT文件
writematrix(data.phase_map, 'phase.xlsx');  % 将变量写入Excel
