% 选择包含CSV文件的文件夹
folderPath = uigetdir('请选择包含CSV文件的文件夹');
if folderPath == 0
    error('未选择文件夹，操作已取消');
end

% 获取所有CSV文件列表
fileList = dir(fullfile(folderPath, '*.csv'));
if isempty(fileList)
    error('所选文件夹中未找到CSV文件');
end

% 创建等待对话框
h = waitbar(0, '开始转换文件...');

% 遍历处理每个文件
for i = 1:length(fileList)
    try
        % 更新等待条进度
        waitbar(i/length(fileList), h, sprintf('正在处理 %d/%d...', i, length(fileList)));
        
        % 获取当前文件信息
        csvName = fileList(i).name;
        csvPath = fullfile(folderPath, csvName);
        
        % 读取CSV文件（自动检测分隔符）
        opts = detectImportOptions(csvPath);
        data = readtable(csvPath, opts);
        
        % 生成输出文件名
        [~, filename, ~] = fileparts(csvName);
        matPath = fullfile(folderPath, [filename '.mat']);
        
        % 保存为MAT文件（包含元数据）
        save(matPath, 'data', '-v7.3');
        fprintf('成功转换: %s → %s\n', csvName, [filename '.mat']);
        
    catch ME
        % 错误处理
        fprintf('转换失败: %s\n原因: %s\n', csvName, ME.message);
        continue;
    end
end

% 关闭等待条
close(h);
disp('批量转换完成！');

% 提示转换结果
successCount = sum(arrayfun(@(x) exist(fullfile(folderPath, [x.name(1:end-4) '.mat']), 'file'), fileList));
fprintf('成功转换 %d/%d 个文件\n', successCount, length(fileList));