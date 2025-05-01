% 选择包含.mat文件的文件夹
folderPath = uigetdir('请选择包含MAT文件的文件夹');
if folderPath == 0
    error('未选择文件夹，操作已取消');
end

% 获取所有.mat文件列表
fileList = dir(fullfile(folderPath, '*.mat'));
if isempty(fileList)
    error('所选文件夹中未找到MAT文件');
end

% 创建等待对话框
h = waitbar(0, '开始转换文件...');
totalFiles = length(fileList);
successCount = 0;

% 遍历处理每个文件
for i = 1:totalFiles
    try
        % 更新等待条
        waitbar(i/totalFiles, h, sprintf('正在处理 %d/%d...', i, totalFiles));
        
        % 加载MAT文件
        fileName = fileList(i).name;
        filePath = fullfile(folderPath, fileName);
        matData = load(filePath);
        
        % 寻找表格变量
        tableVars = struct2cell(matData);
        isTableVar = cellfun(@(x) istable(x), tableVars);
        
        if ~any(isTableVar)
            error('文件中未找到表格数据');
        end
        
        % 获取第一个表格变量（可修改为指定变量名）
        tableData = tableVars{find(isTableVar,1)};
        
        % 验证表格结构
        if width(tableData) ~= 29
            error('表格列数应为29，实际为%d', width(tableData));
        end
        
        % 转换为double矩阵
        matrixData = table2array(tableData)';  % 关键转置操作
        
        % 强制转换为double类型
        matrixData = double(matrixData);
        
        % 保存结果（新文件名添加后缀）
        save(filePath, 'matrixData', '-v7.3');  % 直接覆盖原文件
        
        
        successCount = successCount + 1;
        
    catch ME
        fprintf('转换失败: %s\n原因: %s\n', fileName, ME.message);
    end
end

% 关闭等待条
close(h);

% 显示统计结果
fprintf('\n转换完成！\n成功: %d/%d\n失败: %d/%d\n',...
    successCount, totalFiles, totalFiles-successCount, totalFiles);