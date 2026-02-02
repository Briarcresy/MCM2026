%% 多目标优化：蒙特卡洛模拟求解与帕累托前沿分析
clear; clc; close all;

%% 参数定义（使用分数和科学计数法）
% 常量定义
T_min = 50000/199;  % T的下界
T_max = 1e8/179000; % T的上界
C_min = 350000;     % C的下界
C_max = 73e6/150;   % C的上界

% 归一化分母
norm_T = T_max - T_min;
norm_C = C_max - C_min;

%% 蒙特卡洛模拟 - 生成帕累托前沿数据
fprintf('正在生成帕累托前沿数据...\n');
n_samples = 500000;  % 帕累托分析样本数量

% 生成随机样本
T_rand = T_min + rand(n_samples, 1) * (T_max - T_min);
C_rand = C_min + rand(n_samples, 1) * (C_max - C_min);

% 检查约束条件
valid_mask = true(n_samples, 1);

% 约束条件1: ((C-1725)/10000-35)*(3/41) >= 1 - (179000/100000000)T
% 修改：将C改为C-1725
lhs1 = ((C_rand-1725)/10000 - 35) * (3/41);  % 修改这里
rhs1 = 1 - (179000/1e8) * T_rand;
valid_mask = valid_mask & (lhs1 >= rhs1);

% 约束条件2: ((C-1725)/10000-35)*(3/41) <= (150*10*365)/(100000000*2.5)T
% 修改：将C改为C-1725
lhs2 = lhs1;  % 与约束1左边相同
rhs2 = (150*10*365)/(1e8*2.5) * T_rand;
valid_mask = valid_mask & (lhs2 <= rhs2);

% 提取可行解
feasible_indices = find(valid_mask);
T_feasible = T_rand(feasible_indices);
C_feasible = C_rand(feasible_indices);

fprintf('找到 %d 个可行解（总共 %d 个样本）\n', length(feasible_indices), n_samples);

% 计算两个目标函数（归一化后）
f1_feasible = (T_feasible - T_min) / norm_T;  % T相关目标（越小越好）
f2_feasible = (C_feasible - C_min) / norm_C;  % C相关目标（越小越好）

%% 帕累托前沿识别
fprintf('正在识别帕累托前沿...\n');
n_feasible = length(T_feasible);
is_pareto = true(n_feasible, 1);  % 初始化所有点都为帕累托最优

% 使用朴素方法识别帕累托前沿（对于中等规模数据）
for i = 1:n_feasible
    if is_pareto(i)
        % 检查是否有其他点支配当前点
        dominated = (f1_feasible < f1_feasible(i) & f2_feasible <= f2_feasible(i)) | ...
                    (f1_feasible <= f1_feasible(i) & f2_feasible < f2_feasible(i));
        if any(dominated)
            is_pareto(i) = false;
        end
    end
end

% 提取帕累托最优解
pareto_f1 = f1_feasible(is_pareto);
pareto_f2 = f2_feasible(is_pareto);
pareto_T = T_feasible(is_pareto);
pareto_C = C_feasible(is_pareto);

fprintf('识别出 %d 个帕累托最优解\n', sum(is_pareto));

%% 可视化帕累托前沿
figure('Position', [100, 100, 1400, 500]);

% 子图1: 可行解和帕累托前沿
subplot(1, 3, 1);
% 绘制所有可行解
scatter(f1_feasible, f2_feasible, 10, 'b', 'filled', 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0.3);
hold on;
% 绘制帕累托前沿
[pareto_sorted_f1, sort_idx] = sort(pareto_f1);
pareto_sorted_f2 = pareto_f2(sort_idx);
pareto_sorted_T = pareto_T(sort_idx);
pareto_sorted_C = pareto_C(sort_idx);

plot(pareto_sorted_f1, pareto_sorted_f2, 'r-', 'LineWidth', 3);
scatter(pareto_sorted_f1, pareto_sorted_f2, 50, 'r', 'filled');

xlabel('f_1 = (T - T_{min}) / (T_{max} - T_{min})', 'FontSize', 11);
ylabel('f_2 = (C - C_{min}) / (C_{max} - C_{min})', 'FontSize', 11);
title('帕累托前沿', 'FontSize', 14);
legend('可行解', '帕累托前沿', 'Location', 'best');
grid on;
xlim([0, 1]);
ylim([0, 1]);

% 子图2: 不同权重α对应的最优解在帕累托前沿上的位置
subplot(1, 3, 2);
% 重新绘制帕累托前沿
plot(pareto_sorted_f1, pareto_sorted_f2, 'r-', 'LineWidth', 2);
hold on;

% 选择几个有代表性的α值
alpha_test = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95];
colors = jet(length(alpha_test));
markers = {'o', 's', 'd', '^', 'v', '>', '<'};

for i = 1:length(alpha_test)
    alpha = alpha_test(i);
    
    % 计算加权目标函数
    K_values = alpha * pareto_sorted_f1 + (1-alpha) * pareto_sorted_f2;
    
    % 找到最小值
    [min_K, min_idx] = min(K_values);
    
    % 绘制对应点
    scatter(pareto_sorted_f1(min_idx), pareto_sorted_f2(min_idx), ...
        100, colors(i,:), markers{i}, 'LineWidth', 2);
    
    % 显示α值
    text(pareto_sorted_f1(min_idx)+0.02, pareto_sorted_f2(min_idx)-0.02, ...
        sprintf('α=%.2f', alpha), 'FontSize', 10);
end

xlabel('f_1', 'FontSize', 11);
ylabel('f_2', 'FontSize', 11);
title('不同α值对应的帕累托最优解', 'FontSize', 14);
grid on;
xlim([0, 1]);
ylim([0, 1]);

% 子图3: 帕累托前沿在原始决策空间中的表示
subplot(1, 3, 3);
% 生成网格
T_grid = linspace(T_min, T_max, 100);
C_grid = linspace(C_min, C_max, 100);
[T_mesh, C_mesh] = meshgrid(T_grid, C_grid);

% 计算约束区域 - 注意：这里需要同步修改
% 约束条件1: ((C-1725)/10000-35)*(3/41) >= 1 - (179000/100000000)T
constraint1 = ((C_mesh-1725)/10000 - 35) * (3/41) >= (1 - (179000/1e8) * T_mesh);  % 修改这里
% 约束条件2: ((C-1725)/10000-35)*(3/41) <= (150*10*365)/(100000000*2.5)T
constraint2 = ((C_mesh-1725)/10000 - 35) * (3/41) <= (150*10*365)/(1e8*2.5) * T_mesh;  % 修改这里

feasible_region = constraint1 & constraint2;

% 绘制可行域
contourf(T_mesh, C_mesh, double(feasible_region), [0.5, 1.5], ...
    'FaceColor', [0.8, 0.9, 0.8], 'EdgeColor', 'none');
hold on;

% 绘制约束边界
contour(T_mesh, C_mesh, ((C_mesh-1725)/10000 - 35) * (3/41) - (1 - (179000/1e8) * T_mesh), ...
    [0, 0], 'r-', 'LineWidth', 1.5);  % 约束1边界 - 修改这里
contour(T_mesh, C_mesh, ((C_mesh-1725)/10000 - 35) * (3/41) - (150*10*365)/(1e8*2.5) * T_mesh, ...
    [0, 0], 'b-', 'LineWidth', 1.5);  % 约束2边界 - 修改这里

% 绘制帕累托前沿在决策空间中的点
scatter(pareto_T, pareto_C, 40, 'm', 'filled', 'MarkerFaceAlpha', 0.7);

xlabel('T', 'FontSize', 11);
ylabel('C', 'FontSize', 11);
title('决策空间中的帕累托前沿', 'FontSize', 14);
legend('可行域', '约束1边界', '约束2边界', '帕累托解', 'Location', 'best');
grid on;
xlim([T_min, T_max]);
ylim([C_min, C_max]);

%% 继续原有代码：寻找最优α
fprintf('\n=========== 寻找最优权重α ===========\n');
alpha_values = linspace(0.4, 0.999, 50);  % α从0.4到0.999

% 存储结果
best_K = Inf;
best_T = NaN;
best_C = NaN;
best_alpha = NaN;
results = [];

% 进度条
h = waitbar(0, '正在寻找最优α值...');

for a_idx = 1:length(alpha_values)
    alpha = alpha_values(a_idx);
    
    % 计算加权目标函数
    K = alpha * f1_feasible + (1-alpha) * f2_feasible;
    
    % 找到最小值
    [min_K, min_idx] = min(K);
    
    if min_K < best_K
        best_K = min_K;
        best_T = T_feasible(min_idx);
        best_C = C_feasible(min_idx);
        best_alpha = alpha;
    end
    
    % 记录结果
    results = [results; alpha, min_K, T_feasible(min_idx), C_feasible(min_idx)];
    
    waitbar(a_idx/length(alpha_values), h);
end

close(h);

%% 结果展示
fprintf('\n=========== 优化结果 ===========\n');
fprintf('最优目标函数值 K = %.6f\n', best_K);
fprintf('最优 α = %.4f\n', best_alpha);
fprintf('最优 T = %.6f\n', best_T);
fprintf('最优 C = %.6f\n', best_C);

% 验证约束条件 - 注意：这里需要同步修改
fprintf('约束条件验证:\n');
% 约束1: ((C-1725)/10000-35)*(3/41) >= 1 - (179000/100000000)T
lhs1 = ((best_C-1725)/10000 - 35) * (3/41);  % 修改这里
rhs1 = 1 - (179000/1e8) * best_T;
fprintf('  约束1: %.6f >= %.6f (满足: %s)\n', lhs1, rhs1, ...
    string(lhs1 >= rhs1 - 1e-10));

% 约束2: ((C-1725)/10000-35)*(3/41) <= (150*10*365)/(100000000*2.5)T
lhs2 = lhs1;  % 与约束1左边相同
rhs2 = (150*10*365)/(1e8*2.5) * best_T;
fprintf('  约束2: %.6f <= %.6f (满足: %s)\n', lhs2, rhs2, ...
    string(lhs2 <= rhs2 + 1e-10));

fprintf('  T范围: %.6f ∈ [%.6f, %.6f] (满足: %s)\n', ...
    best_T, T_min, T_max, string(best_T >= T_min-1e-10 & best_T <= T_max+1e-10));
fprintf('  C范围: %.2f ∈ [%.2f, %.2f] (满足: %s)\n', ...
    best_C, C_min, C_max, string(best_C >= C_min-1e-10 & best_C <= C_max+1e-10));

%% 新增：帕累托前沿上的最优解可视化
figure('Position', [100, 100, 1200, 400]);

% 子图1: K随α的变化
subplot(1, 3, 1);
plot(results(:,1), results(:,2), 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('\alpha', 'FontSize', 12);
ylabel('最小K值', 'FontSize', 12);
title('目标函数值K随\alpha的变化', 'FontSize', 14);
grid on;
hold on;
plot(best_alpha, best_K, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
legend('K(\alpha)', '最优值', 'Location', 'best');

% 子图2: 最优解在帕累托前沿上的位置
subplot(1, 3, 2);
scatter(f1_feasible, f2_feasible, 10, 'b', 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
plot(pareto_sorted_f1, pareto_sorted_f2, 'r-', 'LineWidth', 3);

% 计算最优解对应的f1和f2
best_f1 = (best_T - T_min) / norm_T;
best_f2 = (best_C - C_min) / norm_C;
scatter(best_f1, best_f2, 150, 'kp', 'LineWidth', 2, 'MarkerFaceColor', 'y');

xlabel('f_1', 'FontSize', 12);
ylabel('f_2', 'FontSize', 12);
title(sprintf('最优解在帕累托前沿上 (α=%.3f)', best_alpha), 'FontSize', 14);
legend('可行解', '帕累托前沿', '最优解', 'Location', 'best');
grid on;
xlim([0, 1]);
ylim([0, 1]);

% 子图3: 权重α对目标函数分量的影响
subplot(1, 3, 3);
% 提取帕累托前沿上不同α对应的f1和f2值
alpha_range = linspace(0.4, 0.999, 100);
f1_values = zeros(size(alpha_range));
f2_values = zeros(size(alpha_range));

for i = 1:length(alpha_range)
    alpha = alpha_range(i);
    K_values = alpha * pareto_sorted_f1 + (1-alpha) * pareto_sorted_f2;
    [~, min_idx] = min(K_values);
    f1_values(i) = pareto_sorted_f1(min_idx);
    f2_values(i) = pareto_sorted_f2(min_idx);
end

yyaxis left;
plot(alpha_range, f1_values, 'b-', 'LineWidth', 2);
ylabel('f_1 值', 'FontSize', 12);
yyaxis right;
plot(alpha_range, f2_values, 'r-', 'LineWidth', 2);
ylabel('f_2 值', 'FontSize', 12);
xlabel('\alpha', 'FontSize', 12);
title('帕累托最优解随\alpha的变化', 'FontSize', 14);
grid on;
legend('f_1 (T相关)', 'f_2 (C相关)', 'Location', 'best');

%% 详细分析最优α附近 - 注意：这里需要同步修改非线性约束
fprintf('\n=========== 最优α附近详细分析 ===========\n');
alpha_fine = linspace(max(0.4, best_alpha-0.05), min(0.999, best_alpha+0.05), 100);
fine_results = [];

for i = 1:length(alpha_fine)
    alpha = alpha_fine(i);
    
    % 使用fmincon在给定α下优化
    options = optimoptions('fmincon', 'Display', 'off');
    
    % 定义目标函数 - 这里C保持不变，不需要修改
    obj_fun = @(x) alpha * (x(1) - T_min)/norm_T ...
                   + (1-alpha) * (x(2) - C_min)/norm_C;
    
    % 初始点
    x0 = [best_T, best_C];
    
    % 边界约束
    lb = [T_min, C_min];
    ub = [T_max, C_max];
    
    % 非线性约束 - 注意：这里需要修改
    nonlcon = @(x) deal([
        % 约束1: ((C-1725)/10000-35)*(3/41) - (1 - (179000/100000000)T) >= 0
        -(((x(2)-1725)/10000 - 35)*(3/41) - (1 - (179000/1e8)*x(1)));  % 修改这里
        % 约束2: ((C-1725)/10000-35)*(3/41) - (150*10*365)/(100000000*2.5)T <= 0
        (((x(2)-1725)/10000 - 35)*(3/41) - (150*10*365)/(1e8*2.5)*x(1))  % 修改这里
    ], []);
    
    % 优化
    [x_opt, K_opt] = fmincon(obj_fun, x0, [], [], [], [], lb, ub, nonlcon, options);
    
    fine_results = [fine_results; alpha, K_opt, x_opt(1), x_opt(2)];
end

% 找到更精确的最优α
[~, idx] = min(fine_results(:,2));
fprintf('精确最优 α = %.6f\n', fine_results(idx,1));
fprintf('精确最优 K = %.6f\n', fine_results(idx,2));
fprintf('精确最优 T = %.6f\n', fine_results(idx,3));
fprintf('精确最优 C = %.6f\n', fine_results(idx,4));

%% 输出最终推荐
fprintf('\n=========== 最终推荐方案 ===========\n');
fprintf('推荐权重 α = %.4f\n', best_alpha);
fprintf('对应的决策变量:\n');
fprintf('  T = %.6f\n', best_T);
fprintf('  C = %.6f\n', best_C);
fprintf('目标函数值 K = %.6f\n', best_K);
fprintf('\n帕累托分析总结:\n');
fprintf('  可行解数量: %d\n', length(feasible_indices));
fprintf('  帕累托最优解数量: %d\n', sum(is_pareto));
fprintf('  最优解在帕累托前沿上: 是\n');