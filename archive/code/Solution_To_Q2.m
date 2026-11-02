%% ============================================================================
% 火箭与太空电梯运输方案优化模拟（完整专业版）
% 版本：v3.0 - 包含完整可视化与专业分析
% 修改记录：
% 1. λ从0.5降到0.05（大幅降低故障频率）
% 2. 电梯故障成本上限×3（17250000→51750000）
% 3. 优化威布尔分布参数
% 4. 保留全部可视化与分析功能
% ============================================================================

clear; clc; close all;
warning('off', 'all');

%% ============================================================================
% 第一部分：参数设置与初始化
% ============================================================================

fprintf('=============================================\n');
fprintf('火箭与太空电梯运输方案模拟 v3.0\n');
fprintf('模拟次数：100,000次 | 完整可视化版\n');
fprintf('=============================================\n\n');

% ----------------------------------------------------------------------------
% 1.1 基本运输参数
% ----------------------------------------------------------------------------
W0 = 100000000;                % 总运输重量：1亿吨

% 火箭参数（10个基地等效）
w_R = 1500;                    % 火箭单次总运力：10×150 = 1500 吨
c_R = 37000;                   % 火箭单次总成本：10×3700 = 37000 万美元
t_R = 2.5/365;                 % 火箭单次时间：2.5天 = 2.5/365 年

% 太空电梯参数
elevator_capacity = 3*179000;  % 电梯年运输能力：537000 吨/年
elevator_cost_per_ton = 60;    % 电梯单位成本：60 万美元/吨

% 故障概率
rocket_fault_prob = 0.0016;    % 火箭故障概率（0.16%）

% ----------------------------------------------------------------------------
% 1.2 概率分布参数（已优化）
% ----------------------------------------------------------------------------
% 泊松分布（电梯年故障次数）
lambda_elevator = 0.05;        % 年均故障次数：从0.5降到0.05

% 混合威布尔分布参数
% 太空电梯故障延误分布（已优化）
elevator_weibull_params = struct(...
    'beta1', 2.0, ...          % 形状参数1：从1.2提高到2.0
    'theta1', 180/365, ...     % 尺度参数1：从500/365降到180/365
    'beta2', 1.5, ...          % 形状参数2：从4降到1.5
    'theta2', 25, ...          % 尺度参数2：从6000/365改为25
    'alpha', 0.1 ...           % 混合比例：从0.35降到0.1
);

% 火箭故障延误分布（已优化）
rocket_weibull_params = struct(...
    'beta1', 1.5, ...          % 形状参数1：从0.8提高到1.5
    'theta1', 10/365, ...      % 尺度参数1：从20/365降到10/365
    'beta2', 2.2, ...          % 形状参数2：保持2.2
    'theta2', 70/365, ...      % 尺度参数2：保持70/365
    'alpha', 0.9 ...           % 混合比例：从0.7提高到0.9
);

% ----------------------------------------------------------------------------
% 1.3 成本函数参数（上限已修正）
% ----------------------------------------------------------------------------
% 电梯故障成本函数：f(t) = 51750000 / (1 + exp(-((t+19.5)/65)*(t-13)))
% 火箭故障成本函数：f(t) = 1200 / (1 + exp(-20*(t - 90/365)))

% ----------------------------------------------------------------------------
% 1.4 模拟参数
% ----------------------------------------------------------------------------
num_simulations = 100000;      % 模拟次数
batch_threshold = 10;          % 批量处理阈值
remaining_threshold = 3*179000; % 剩余量阈值

% 剩余量分配比例
ratio_rocket = 73/252;
ratio_elevator = (252-73)/252;

% ----------------------------------------------------------------------------
% 1.5 结果存储初始化
% ----------------------------------------------------------------------------
results = struct();
results.total_cost = zeros(num_simulations, 1);      % 总成本（万美元）
results.total_time = zeros(num_simulations, 1);      % 总时间（年）
results.rocket_time = zeros(num_simulations, 1);     % 火箭总时间（年）
results.elevator_time = zeros(num_simulations, 1);   % 电梯总时间（年）
results.rocket_cost = zeros(num_simulations, 1);     % 火箭总成本（万美元）
results.elevator_cost = zeros(num_simulations, 1);   % 电梯总成本（万美元）
results.rocket_weight = zeros(num_simulations, 1);   % 火箭运输总量（吨）
results.elevator_weight = zeros(num_simulations, 1); % 电梯运输总量（吨）
results.iterations = zeros(num_simulations, 1);      % 迭代次数
results.rocket_trips = zeros(num_simulations, 1);    % 火箭运输次数
results.elevator_years = zeros(num_simulations, 1);  % 电梯运输年数
results.rocket_faults = zeros(num_simulations, 1);   % 火箭故障次数
results.elevator_faults = zeros(num_simulations, 1); % 电梯故障次数

% 随机数种子设置
rng(2024, 'twister');

% ----------------------------------------------------------------------------
% 1.6 理论成本计算
% ----------------------------------------------------------------------------
fprintf('【理论成本边界验证】\n');
conversion_factor = 1e8;  % 1万亿美元 = 1e8万美元

rocket_cost_per_ton = c_R / w_R;
rocket_min_cost = W0 * rocket_cost_per_ton;
elevator_min_cost = W0 * elevator_cost_per_ton;

fprintf('火箭单位成本: %.2f 万美元/吨\n', rocket_cost_per_ton);
fprintf('火箭理论最小成本: %.2f 万亿美元\n', rocket_min_cost/conversion_factor);
fprintf('电梯单位成本: %.2f 万美元/吨\n', elevator_cost_per_ton);
fprintf('电梯理论最小成本: %.2f 万亿美元\n', elevator_min_cost/conversion_factor);
fprintf('\n');

% 分析分布特性
fprintf('【分布参数分析】\n');
fprintf('电梯故障频率: λ=%.3f (平均每%.1f年一次故障)\n', lambda_elevator, 1/lambda_elevator);
fprintf('电梯长延误概率: α=%.3f (%.1f%%概率发生长延误)\n', elevator_weibull_params.alpha, elevator_weibull_params.alpha*100);
fprintf('火箭短延误概率: α=%.3f (%.1f%%概率发生短延误)\n', rocket_weibull_params.alpha, rocket_weibull_params.alpha*100);
fprintf('\n');

fprintf('参数设置完成，开始模拟...\n');
fprintf('进度：');

%% ============================================================================
% 第二部分：辅助函数定义
% ============================================================================

% 2.1 混合威布尔分布随机数生成器
function t_delay = mixed_weibull_rnd(params)
    u = rand();
    if u < params.alpha
        t_delay = wblrnd(params.theta1, params.beta1);
    else
        t_delay = wblrnd(params.theta2, params.beta2);
    end
end

% 2.2 电梯故障成本函数（上限×3）
function cost = elevator_fault_cost(t_delay)
    exponent = -((t_delay + 19.5) / 65) * (t_delay - 13);
    cost = 51750000 / (1 + exp(exponent));  % 17250000 → 51750000
end

% 2.3 火箭故障成本函数
function cost = rocket_fault_cost(t_delay)
    exponent = -20 * (t_delay - 90/365);
    cost = 1200 / (1 + exp(exponent));
end

% 2.4 模拟一年电梯运输
function [weight, time, cost, fault_count] = simulate_elevator_year(lambda, weibull_params)
    fault_count = poissrnd(lambda);
    total_delay = 0;
    total_fault_cost = 0;
    
    for i = 1:fault_count
        t_delay = mixed_weibull_rnd(weibull_params);
        fault_cost = elevator_fault_cost(t_delay);
        total_delay = total_delay + t_delay;
        total_fault_cost = total_fault_cost + fault_cost;
    end
    
    effective_days = 365 - total_delay * 365;
    if effective_days < 0
        effective_days = 0;
    end
    effective_years = effective_days / 365;
    
    annual_capacity = 3 * 179000;
    weight = effective_years * annual_capacity;
    max_annual_cost = annual_capacity * 60;
    transport_cost = effective_years * max_annual_cost;
    
    cost = transport_cost + total_fault_cost;
    time = 1 + total_delay;
end

% 2.5 模拟一次火箭运输
function [time_add, cost_add, weight_add, fault_occurred] = ...
    simulate_rocket_trip(fault_prob, weibull_params, batch_size)
    
    global t_R c_R w_R;
    
    if isempty(t_R)
        t_R = 2.5/365;
        c_R = 37000;
        w_R = 1500;
    end
    
    if rand() < fault_prob
        fault_occurred = true;
        t_delay = mixed_weibull_rnd(weibull_params);
        fault_cost = rocket_fault_cost(t_delay);
        time_add = t_delay;
        cost_add = fault_cost;
        weight_add = 0;
    else
        fault_occurred = false;
        time_add = t_R * batch_size;
        cost_add = c_R * batch_size;
        if batch_size == 10
            weight_add = w_R;
        else
            weight_add = w_R * batch_size;
        end
    end
end

%% ============================================================================
% 第三部分：主模拟循环
% ============================================================================

global t_R c_R w_R;
t_R = 2.5/365;
c_R = 37000;
w_R = 1500;

progress_interval = num_simulations / 50;
progress_count = 0;
start_time = tic;

for sim_idx = 1:num_simulations
    % 初始化累计变量
    T_R = 0; T_E = 0; C_R = 0; C_E = 0;
    W_total = 0; W_R = 0; W_E = 0;
    rocket_trip_count = 0; elevator_year_count = 0;
    rocket_fault_count = 0; elevator_fault_count = 0;
    iteration_count = 0;
    
    % 主循环
    while (W0 - W_total) >= remaining_threshold
        iteration_count = iteration_count + 1;
        
        if (T_R - T_E) >= 0
            elevator_year_count = elevator_year_count + 1;
            [W_E_year, T_E_year, C_E_year, fault_count] = simulate_elevator_year(...
                lambda_elevator, elevator_weibull_params);
            
            W_E = W_E + W_E_year;
            T_E = T_E + T_E_year;
            C_E = C_E + C_E_year;
            elevator_fault_count = elevator_fault_count + fault_count;
            W_total = W_R + W_E;
            
            if (W0 - W_total) < remaining_threshold
                break;
            end
        end
        
        % 火箭运输
        if rand() < rocket_fault_prob
            rocket_fault_count = rocket_fault_count + 1;
            t_delay = mixed_weibull_rnd(rocket_weibull_params);
            fault_cost = rocket_fault_cost(t_delay);
            T_R = T_R + t_delay;
            C_R = C_R + fault_cost;
        else
            rocket_trip_count = rocket_trip_count + 10;
            T_R = T_R + t_R * 10;
            C_R = C_R + c_R * 10;
            W_R = W_R + w_R;
        end
        
        W_total = W_R + W_E;
        
        if iteration_count > 500000
            break;
        end
    end
    
    % 剩余量处理
    remaining_weight = W0 - W_total;
    
    if remaining_weight > 0
        deltaW1 = remaining_weight * ratio_rocket;
        deltaW2 = remaining_weight * ratio_elevator;
        deltaD1 = ceil(deltaW1 / w_R);
        deltaD2 = deltaW2 / elevator_capacity;
        
        if deltaD2 > 0
            N_faults_remaining = poissrnd(lambda_elevator * deltaD2);
            total_delay_e = 0;
            total_fault_cost_e = 0;
            
            for j = 1:N_faults_remaining
                t_delay_e = mixed_weibull_rnd(elevator_weibull_params);
                fault_cost_e = elevator_fault_cost(t_delay_e);
                total_delay_e = total_delay_e + t_delay_e;
                total_fault_cost_e = total_fault_cost_e + fault_cost_e;
            end
            
            C_E = C_E + total_fault_cost_e + deltaW2 * elevator_cost_per_ton;
            T_E = T_E + total_delay_e + deltaD2;
            W_total = W_total + deltaW2;
            W_E = W_E + deltaW2;
            elevator_year_count = elevator_year_count + deltaD2;
            elevator_fault_count = elevator_fault_count + N_faults_remaining;
        end
        
        if deltaD1 > 0
            k = 0;
            while (deltaD1 - k) >= batch_threshold
                [time_add, cost_add, weight_add, fault_occurred] = ...
                    simulate_rocket_trip(rocket_fault_prob, rocket_weibull_params, 10);
                
                T_R = T_R + time_add;
                C_R = C_R + cost_add;
                
                if fault_occurred
                    rocket_fault_count = rocket_fault_count + 1;
                else
                    W_R = W_R + weight_add;
                    k = k + 10;
                    rocket_trip_count = rocket_trip_count + 10;
                end
            end
            
            remaining_trips = deltaD1 - k;
            if remaining_trips > 0
                [time_add, cost_add, weight_add, fault_occurred] = ...
                    simulate_rocket_trip(rocket_fault_prob, rocket_weibull_params, remaining_trips);
                
                T_R = T_R + time_add;
                C_R = C_R + cost_add;
                
                if fault_occurred
                    rocket_fault_count = rocket_fault_count + 1;
                else
                    W_R = W_R + weight_add;
                    rocket_trip_count = rocket_trip_count + remaining_trips;
                end
            end
            
            W_total = W_total + deltaW1;
        end
    end
    
    % 最终汇总
    total_cost = C_R + C_E;
    total_time = max(T_R, T_E);
    
    results.total_cost(sim_idx) = total_cost;
    results.total_time(sim_idx) = total_time;
    results.rocket_time(sim_idx) = T_R;
    results.elevator_time(sim_idx) = T_E;
    results.rocket_cost(sim_idx) = C_R;
    results.elevator_cost(sim_idx) = C_E;
    results.rocket_weight(sim_idx) = W_R;
    results.elevator_weight(sim_idx) = W_E;
    results.iterations(sim_idx) = iteration_count;
    results.rocket_trips(sim_idx) = rocket_trip_count;
    results.elevator_years(sim_idx) = elevator_year_count;
    results.rocket_faults(sim_idx) = rocket_fault_count;
    results.elevator_faults(sim_idx) = elevator_fault_count;
    
    % 进度显示
    if sim_idx >= progress_count * progress_interval
        fprintf('█');
        progress_count = progress_count + 1;
        
        if mod(progress_count, 5) == 0
            elapsed_time = toc(start_time);
            estimated_total = elapsed_time / (sim_idx/num_simulations);
            remaining_time = estimated_total - elapsed_time;
            fprintf(' (%.0f%%, 剩余约%.0f分钟)', ...
                sim_idx/num_simulations*100, remaining_time/60);
        end
    end
end

total_run_time = toc(start_time);
fprintf('\n模拟完成！总耗时: %.1f 分钟\n\n', total_run_time/60);

%% ============================================================================
% 第四部分：基本结果分析与输出
% ============================================================================

fprintf('=============================================\n');
fprintf('基本统计结果\n');
fprintf('=============================================\n\n');

fprintf('【模拟概况】\n');
fprintf('模拟次数: %d\n', num_simulations);
fprintf('总运行时间: %.1f 分钟\n', total_run_time/60);
fprintf('平均迭代次数: %.1f\n', mean(results.iterations));
fprintf('\n');

fprintf('【总成本统计】（单位：万亿美元）\n');
fprintf('均值: %.2f\n', mean(results.total_cost)/conversion_factor);
fprintf('标准差: %.2f\n', std(results.total_cost)/conversion_factor);
fprintf('最小值: %.2f\n', min(results.total_cost)/conversion_factor);
fprintf('中位数: %.2f\n', median(results.total_cost)/conversion_factor);
fprintf('最大值: %.2f\n', max(results.total_cost)/conversion_factor);
fprintf('变异系数: %.3f\n', std(results.total_cost)/mean(results.total_cost));
fprintf('\n');

fprintf('【总时间统计】（单位：年）\n');
fprintf('均值: %.1f\n', mean(results.total_time));
fprintf('标准差: %.1f\n', std(results.total_time));
fprintf('最小值: %.1f\n', min(results.total_time));
fprintf('中位数: %.1f\n', median(results.total_time));
fprintf('最大值: %.1f\n', max(results.total_time));
fprintf('变异系数: %.3f\n', std(results.total_time)/mean(results.total_time));
fprintf('\n');

fprintf('【成本构成分析】\n');
rocket_cost_ratio = mean(results.rocket_cost ./ results.total_cost) * 100;
elevator_cost_ratio = mean(results.elevator_cost ./ results.total_cost) * 100;
fprintf('火箭成本占比: %.1f%%\n', rocket_cost_ratio);
fprintf('电梯成本占比: %.1f%%\n', elevator_cost_ratio);
fprintf('火箭单位成本: %.2f 万美元/吨\n', mean(results.rocket_cost ./ results.rocket_weight));
fprintf('电梯单位成本: %.2f 万美元/吨\n', mean(results.elevator_cost ./ results.elevator_weight));
fprintf('\n');

fprintf('【运输量分配】\n');
rocket_weight_ratio = mean(results.rocket_weight / W0) * 100;
elevator_weight_ratio = mean(results.elevator_weight / W0) * 100;
fprintf('火箭运输量占比: %.1f%%\n', rocket_weight_ratio);
fprintf('电梯运输量占比: %.1f%%\n', elevator_weight_ratio);
fprintf('平均火箭运输次数: %.0f 次\n', mean(results.rocket_trips));
fprintf('平均电梯运输年数: %.1f 年\n', mean(results.elevator_years));
fprintf('\n');

fprintf('【故障统计】\n');
fprintf('平均电梯故障次数: %.2f 次 (每%.1f年一次)\n', ...
    mean(results.elevator_faults), mean(results.elevator_years)/mean(results.elevator_faults));
fprintf('平均火箭故障次数: %.2f 次 (每%.0f次运输一次)\n', ...
    mean(results.rocket_faults), mean(results.rocket_trips)/mean(results.rocket_faults));
fprintf('电梯故障总延误: %.1f 年\n', mean(results.elevator_time - results.elevator_years));
fprintf('火箭故障总延误: %.1f 年\n', mean(results.rocket_time - results.rocket_trips * t_R));
fprintf('\n');

fprintf('【时间目标评估】\n');
time_ranges = [0, 180, 300, 450, 550, inf];
range_labels = {'<180年', '180-300年', '300-450年', '450-550年', '>550年'};

for i = 1:length(range_labels)-1
    count = sum(results.total_time >= time_ranges(i) & results.total_time < time_ranges(i+1));
    percentage = count / num_simulations * 100;
    avg_cost = mean(results.total_cost(results.total_time >= time_ranges(i) & results.total_time < time_ranges(i+1))) / conversion_factor;
    
    if count > 0
        fprintf('%s: %d次 (%.1f%%), 平均成本: %.1f万亿美元\n', ...
            range_labels{i}, count, percentage, avg_cost);
    end
end

if mean(results.total_time) >= 180 && mean(results.total_time) <= 550
    fprintf('✅ 平均时间在目标范围内 (180-550年)\n');
elseif mean(results.total_time) < 180
    fprintf('⚠️  平均时间低于目标下限 (180年)，可考虑略微增加故障频率\n');
else
    fprintf('⚠️  平均时间超过目标上限 (550年)，可考虑进一步降低故障频率\n');
end

%% ============================================================================
% 第五部分：专业可视化（6个核心图表）
% ============================================================================

fprintf('\n=============================================\n');
fprintf('生成专业可视化图表\n');
fprintf('=============================================\n\n');

% 设置图形参数
set(0, 'DefaultAxesFontSize', 11);
set(0, 'DefaultTextFontSize', 12);
set(0, 'DefaultLineLineWidth', 1.5);

% ----------------------------------------------------------------------------
% 图1：成本-时间关系散点图（核心图表）
% ----------------------------------------------------------------------------
figure('Position', [50, 50, 1000, 700], 'Name', '图1: 成本-时间关系', 'NumberTitle', 'off');

% 散点图，颜色表示火箭成本比例
scatter(results.total_time, results.total_cost/conversion_factor, 8, ...
    results.rocket_cost ./ results.total_cost * 100, 'filled', ...
    'MarkerEdgeAlpha', 0.3, 'MarkerFaceAlpha', 0.5);
colormap(jet);
c = colorbar;
c.Label.String = '火箭成本占比 (%)';
caxis([0, 100]);

% 添加标签和标题
xlabel('总时间（年）', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('总成本（万亿美元）', 'FontSize', 13, 'FontWeight', 'bold');
title(sprintf('运输方案成本-时间分布 (n=%d)', num_simulations), ...
    'FontSize', 14, 'FontWeight', 'bold');
grid on;

% 添加理论边界线和目标时间范围
hold on;
plot([180, 180], ylim, 'g--', 'LineWidth', 2);
plot([550, 550], ylim, 'g--', 'LineWidth', 2);
plot(xlim, [rocket_min_cost/conversion_factor, rocket_min_cost/conversion_factor], 'r--', 'LineWidth', 1.5);
plot(xlim, [elevator_min_cost/conversion_factor, elevator_min_cost/conversion_factor], 'b--', 'LineWidth', 1.5);

% 添加图例
legend('模拟结果', '目标下限(180年)', '目标上限(550年)', ...
    '火箭理论最小成本', '电梯理论最小成本', 'Location', 'best', 'FontSize', 10);

% 添加统计信息文本框
stats_text = sprintf('均值: %.1f万亿美元, %.1f年\n中位数: %.1f万亿美元, %.1f年\n目标范围内: %.1f%%', ...
    mean(results.total_cost)/conversion_factor, mean(results.total_time), ...
    median(results.total_cost)/conversion_factor, median(results.total_time), ...
    sum(results.total_time >= 180 & results.total_time <= 550)/num_simulations*100);
annotation('textbox', [0.15, 0.75, 0.25, 0.1], 'String', stats_text, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'FontSize', 9);

hold off;

% ----------------------------------------------------------------------------
% 图2：成本构成分析
% ----------------------------------------------------------------------------
figure('Position', [100, 100, 1200, 450], 'Name', '图2: 成本构成分析', 'NumberTitle', 'off');

subplot(1, 3, 1);
% 火箭成本比例直方图
histogram(results.rocket_cost ./ results.total_cost * 100, 40, ...
    'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'black', 'FaceAlpha', 0.7);
xlabel('火箭成本占比 (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('频数', 'FontSize', 12, 'FontWeight', 'bold');
title('火箭成本占比分布', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
hold on;
mean_ratio = mean(results.rocket_cost ./ results.total_cost * 100);
plot([mean_ratio, mean_ratio], ylim, 'r-', 'LineWidth', 2);
text(mean_ratio+2, max(ylim)*0.9, sprintf('均值: %.1f%%', mean_ratio), 'Color', 'r', 'FontSize', 10);
hold off;

subplot(1, 3, 2);
% 成本箱线图比较
box_data = [results.rocket_cost/conversion_factor, results.elevator_cost/conversion_factor];
boxplot(box_data, 'Labels', {'火箭成本', '电梯成本'}, 'Colors', 'rb', 'Widths', 0.6);
ylabel('成本（万亿美元）', 'FontSize', 12, 'FontWeight', 'bold');
title('成本构成箱线图', 'FontSize', 13, 'FontWeight', 'bold');
grid on;

subplot(1, 3, 3);
% 成本占比与时间关系
scatter(results.total_time, results.rocket_cost ./ results.total_cost * 100, 10, ...
    'filled', 'MarkerFaceColor', [0.4, 0.8, 0.4], 'MarkerEdgeColor', 'black', 'MarkerFaceAlpha', 0.5);
xlabel('总时间（年）', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('火箭成本占比 (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('时间与成本占比关系', 'FontSize', 13, 'FontWeight', 'bold');
grid on;

% ----------------------------------------------------------------------------
% 图3：时间分布分析
% ----------------------------------------------------------------------------
figure('Position', [150, 150, 1200, 400], 'Name', '图3: 时间分布分析', 'NumberTitle', 'off');

subplot(1, 3, 1);
% 总时间直方图
histogram(results.total_time, 40, 'FaceColor', [0.8, 0.4, 0.2], ...
    'EdgeColor', 'black', 'FaceAlpha', 0.7);
xlabel('总时间（年）', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('频数', 'FontSize', 12, 'FontWeight', 'bold');
title('总时间分布', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
hold on;
plot([180, 180], ylim, 'g--', 'LineWidth', 2);
plot([550, 550], ylim, 'g--', 'LineWidth', 2);
hold off;

subplot(1, 3, 2);
% 火箭vs电梯时间散点图
scatter(results.rocket_time, results.elevator_time, 10, ...
    'filled', 'MarkerFaceColor', [0.2, 0.8, 0.4], 'MarkerEdgeColor', 'black', ...
    'MarkerFaceAlpha', 0.5);
xlabel('火箭时间（年）', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('电梯时间（年）', 'FontSize', 12, 'FontWeight', 'bold');
title('火箭vs电梯时间关系', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
hold on;
max_val = max([max(results.rocket_time), max(results.elevator_time)]);
plot([0, max_val], [0, max_val], 'r--', 'LineWidth', 1.5);
text(max_val*0.7, max_val*0.6, '总时间 = max(火箭,电梯)', 'Color', 'r', 'FontSize', 10, 'Rotation', 45);
hold off;

subplot(1, 3, 3);
% 时间构成饼图
avg_rocket_time = mean(results.rocket_time);
avg_elevator_time = mean(results.elevator_time);
time_overlap = max(0, avg_rocket_time + avg_elevator_time - mean(results.total_time));
time_sizes = [avg_rocket_time - time_overlap, avg_elevator_time - time_overlap, time_overlap];
pie(time_sizes, {'火箭时间', '电梯时间', '并行重叠'});
colormap([0.2, 0.6, 0.8; 0.8, 0.4, 0.2; 0.6, 0.6, 0.6]);
title('平均时间构成', 'FontSize', 13, 'FontWeight', 'bold');

% ----------------------------------------------------------------------------
% 图4：运输量分配分析
% ----------------------------------------------------------------------------
figure('Position', [200, 200, 1000, 450], 'Name', '图4: 运输量分配分析', 'NumberTitle', 'off');

subplot(1, 2, 1);
% 运输量分配散点图
scatter(results.rocket_weight/1e6, results.elevator_weight/1e6, 10, ...
    'filled', 'MarkerFaceColor', [0.4, 0.4, 0.6], 'MarkerEdgeColor', 'black', ...
    'MarkerFaceAlpha', 0.5);
xlabel('火箭运输量（百万吨）', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('电梯运输量（百万吨）', 'FontSize', 12, 'FontWeight', 'bold');
title('运输量分配关系', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
hold on;
max_val = max([max(results.rocket_weight), max(results.elevator_weight)])/1e6;
plot([0, max_val], [W0/1e6, W0/1e6-max_val], 'r--', 'LineWidth', 2);
text(max_val*0.6, (W0/1e6-max_val*0.6)*1.05, '总运输量=100百万吨', 'Color', 'r', 'FontSize', 10);
mean_rocket = mean(results.rocket_weight)/1e6;
mean_elevator = mean(results.elevator_weight)/1e6;
plot(mean_rocket, mean_elevator, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(mean_rocket*1.05, mean_elevator*0.95, sprintf('均值\n(%.1f, %.1f)', mean_rocket, mean_elevator), 'Color', 'r', 'FontSize', 9);
hold off;

subplot(1, 2, 2);
% 运输量占比直方图
weight_ratio = results.rocket_weight ./ (results.rocket_weight + results.elevator_weight) * 100;
histogram(weight_ratio, 40, 'FaceColor', [0.6, 0.2, 0.8], ...
    'EdgeColor', 'black', 'FaceAlpha', 0.7);
xlabel('火箭运输量占比 (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('频数', 'FontSize', 12, 'FontWeight', 'bold');
title('火箭运输量占比分布', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
hold on;
theoretical_ratio = ratio_rocket * 100;
plot([theoretical_ratio, theoretical_ratio], ylim, 'r--', 'LineWidth', 2);
text(theoretical_ratio+3, max(ylim)*0.9, sprintf('理论值: %.1f%%', theoretical_ratio), 'Color', 'r', 'FontSize', 10);
hold off;

% ----------------------------------------------------------------------------
% 图5：收敛性分析
% ----------------------------------------------------------------------------
figure('Position', [250, 250, 1000, 400], 'Name', '图5: 收敛性分析', 'NumberTitle', 'off');

cumulative_mean_cost = cumsum(results.total_cost) ./ (1:num_simulations)';
cumulative_mean_time = cumsum(results.total_time) ./ (1:num_simulations)';

subplot(1, 2, 1);
plot(1:num_simulations, cumulative_mean_cost/conversion_factor, 'b-', 'LineWidth', 1.5);
xlabel('模拟次数', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('累计平均成本（万亿美元）', 'FontSize', 12, 'FontWeight', 'bold');
title('成本收敛性分析', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
final_value = cumulative_mean_cost(end)/conversion_factor;
text(num_simulations*0.7, final_value*1.05, sprintf('最终值: %.2f', final_value), 'Color', 'b', 'FontSize', 10);

subplot(1, 2, 2);
plot(1:num_simulations, cumulative_mean_time, 'r-', 'LineWidth', 1.5);
xlabel('模拟次数', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('累计平均时间（年）', 'FontSize', 12, 'FontWeight', 'bold');
title('时间收敛性分析', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
final_time = cumulative_mean_time(end);
text(num_simulations*0.7, final_time*1.05, sprintf('最终值: %.1f年', final_time), 'Color', 'r', 'FontSize', 10);

% ----------------------------------------------------------------------------
% 图6：关键变量相关性分析
% ----------------------------------------------------------------------------
figure('Position', [300, 300, 900, 700], 'Name', '图6: 相关性分析', 'NumberTitle', 'off');

variables = [results.total_cost/conversion_factor, results.total_time, ...
    results.rocket_cost./results.total_cost*100, ...
    results.rocket_weight/W0*100, results.rocket_faults, results.elevator_faults];
var_names = {'总成本(万亿$)', '总时间(年)', '火箭成本占比(%)', ...
    '火箭运量占比(%)', '火箭故障数', '电梯故障数'};

corr_matrix = corrcoef(variables);

imagesc(corr_matrix);
colormap(jet);
c = colorbar;
c.Label.String = '相关系数';
caxis([-1, 1]);

for i = 1:size(corr_matrix, 1)
    for j = 1:size(corr_matrix, 2)
        text_color = ifelse(abs(corr_matrix(i, j)) > 0.5, 'white', 'black');
        text(j, i, sprintf('%.2f', corr_matrix(i, j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', text_color);
    end
end

set(gca, 'XTick', 1:length(var_names), 'XTickLabel', var_names, 'FontSize', 10);
set(gca, 'YTick', 1:length(var_names), 'YTickLabel', var_names, 'FontSize', 10);
title('关键变量相关系数矩阵', 'FontSize', 14, 'FontWeight', 'bold');
axis image;
xtickangle(45);

%% ============================================================================
% 第六部分：高级统计分析
% ============================================================================

fprintf('\n=============================================\n');
fprintf('高级统计分析\n');
fprintf('=============================================\n\n');

% ----------------------------------------------------------------------------
% 6.1 Pareto前沿分析
% ----------------------------------------------------------------------------
fprintf('【Pareto前沿分析】\n');

is_pareto = true(num_simulations, 1);
for i = 1:num_simulations
    for j = 1:num_simulations
        if i ~= j
            if (results.total_cost(j) < results.total_cost(i) && ...
                results.total_time(j) <= results.total_time(i)) || ...
               (results.total_cost(j) <= results.total_cost(i) && ...
                results.total_time(j) < results.total_time(i))
                is_pareto(i) = false;
                break;
            end
        end
    end
end

pareto_indices = find(is_pareto);
fprintf('Pareto前沿解数量: %d (占 %.2f%%)\n', ...
    length(pareto_indices), length(pareto_indices)/num_simulations*100);

% 绘制Pareto前沿图
figure('Position', [350, 350, 800, 600], 'Name', 'Pareto前沿分析', 'NumberTitle', 'off');

scatter(results.total_time, results.total_cost/conversion_factor, 15, ...
    [0.8, 0.8, 0.8], 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
scatter(results.total_time(pareto_indices), ...
    results.total_cost(pareto_indices)/conversion_factor, 40, ...
    'r', 'filled', 'MarkerEdgeColor', 'black', 'LineWidth', 1);
xlabel('总时间（年）', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('总成本（万亿美元）', 'FontSize', 13, 'FontWeight', 'bold');
title(sprintf('Pareto前沿解 (n=%d, 占%.1f%%)', ...
    length(pareto_indices), length(pareto_indices)/num_simulations*100), ...
    'FontSize', 14, 'FontWeight', 'bold');
legend('所有解', 'Pareto前沿解', 'Location', 'best', 'FontSize', 11);
grid on;

% 添加目标时间范围
plot([180, 180], ylim, 'g--', 'LineWidth', 2);
plot([550, 550], ylim, 'g--', 'LineWidth', 2);
text(180, min(ylim) + (max(ylim)-min(ylim))*0.05, '180年', 'Color', 'g', 'FontSize', 10);
text(550, min(ylim) + (max(ylim)-min(ylim))*0.05, '550年', 'Color', 'g', 'FontSize', 10);

hold off;

% ----------------------------------------------------------------------------
% 6.2 方案类型聚类分析
% ----------------------------------------------------------------------------
fprintf('\n【方案类型聚类分析】\n');

cost_ratio = results.rocket_cost ./ results.total_cost;
rocket_dominant = cost_ratio > 0.7;
balanced = cost_ratio >= 0.3 & cost_ratio <= 0.7;
elevator_dominant = cost_ratio < 0.3;

fprintf('火箭主导方案 (>70%%火箭成本): %d (%.1f%%)\n', ...
    sum(rocket_dominant), sum(rocket_dominant)/num_simulations*100);
fprintf('均衡方案 (30%%-70%%火箭成本): %d (%.1f%%)\n', ...
    sum(balanced), sum(balanced)/num_simulations*100);
fprintf('电梯主导方案 (<30%%火箭成本): %d (%.1f%%)\n', ...
    sum(elevator_dominant), sum(elevator_dominant)/num_simulations*100);

% 绘制聚类结果
figure('Position', [400, 400, 1000, 400], 'Name', '方案类型分析', 'NumberTitle', 'off');

subplot(1, 2, 1);
type_counts = [sum(rocket_dominant), sum(balanced), sum(elevator_dominant)];
type_labels = {'火箭主导', '均衡', '电梯主导'};
pie(type_counts, type_labels);
colormap([0.8, 0.2, 0.2; 0.2, 0.8, 0.2; 0.2, 0.2, 0.8]);
title('方案类型分布', 'FontSize', 13, 'FontWeight', 'bold');

subplot(1, 2, 2);
gscatter(results.total_time, results.total_cost/conversion_factor, ...
    rocket_dominant*2 + balanced*1 + elevator_dominant*0, ...
    'rgb', 'o^s', 15, 'on');
xlabel('总时间（年）', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('总成本（万亿美元）', 'FontSize', 12, 'FontWeight', 'bold');
title('不同方案类型的成本-时间关系', 'FontSize', 13, 'FontWeight', 'bold');
legend(type_labels, 'Location', 'best', 'FontSize', 10);
grid on;
hold on;
plot([180, 180], ylim, 'g--', 'LineWidth', 1);
plot([550, 550], ylim, 'g--', 'LineWidth', 1);
hold off;

% ----------------------------------------------------------------------------
% 6.3 参数灵敏度分析（简化版）
% ----------------------------------------------------------------------------
fprintf('\n【参数灵敏度分析】\n');

% 计算各变量与总时间的相关性
variables_for_sensitivity = [results.total_time, ...
    results.rocket_faults, results.elevator_faults, ...
    results.rocket_trips, results.elevator_years, ...
    results.rocket_cost./results.total_cost*100];
var_names_sens = {'总时间', '火箭故障数', '电梯故障数', '火箭次数', '电梯年数', '火箭成本占比'};

corr_with_time = corr(variables_for_sensitivity);
time_correlations = corr_with_time(1, 2:end);

fprintf('各因素与总时间的相关系数：\n');
for i = 1:length(time_correlations)
    fprintf('  %s: %.3f\n', var_names_sens{i+1}, time_correlations(i));
end

% 绘制灵敏度条形图
figure('Position', [450, 450, 800, 400], 'Name', '参数灵敏度分析', 'NumberTitle', 'off');

bar(abs(time_correlations), 'FaceColor', [0.4, 0.6, 0.8], 'EdgeColor', 'black');
set(gca, 'XTickLabel', var_names_sens(2:end), 'XTickLabelRotation', 45);
ylabel('与总时间的绝对相关系数', 'FontSize', 12, 'FontWeight', 'bold');
title('各因素对总时间的影响程度', 'FontSize', 13, 'FontWeight', 'bold');
grid on;

% 添加数值标签
for i = 1:length(time_correlations)
    text(i, abs(time_correlations(i)) + 0.01, sprintf('%.3f', time_correlations(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10);
end

%% ============================================================================
% 第七部分：结果保存与报告生成
% ============================================================================

fprintf('\n=============================================\n');
fprintf('结果保存与报告\n');
fprintf('=============================================\n\n');

% 保存详细结果
result_table = table(...
    results.total_cost/conversion_factor, ...
    results.total_time, ...
    results.rocket_time, ...
    results.elevator_time, ...
    results.rocket_cost/conversion_factor, ...
    results.elevator_cost/conversion_factor, ...
    results.rocket_weight/1e6, ...
    results.elevator_weight/1e6, ...
    results.rocket_trips, ...
    results.elevator_years, ...
    results.rocket_faults, ...
    results.elevator_faults, ...
    results.iterations, ...
    'VariableNames', {...
    'TotalCost_TrillionUSD', 'TotalTime_Year', 'RocketTime_Year', 'ElevatorTime_Year', ...
    'RocketCost_TrillionUSD', 'ElevatorCost_TrillionUSD', ...
    'RocketWeight_MillionTon', 'ElevatorWeight_MillionTon', ...
    'RocketTrips', 'ElevatorYears', 'RocketFaults', 'ElevatorFaults', 'Iterations'});

csv_filename = 'complete_simulation_results_v3.csv';
writetable(result_table, csv_filename);
fprintf('详细结果已保存: %s\n', csv_filename);

% 保存汇总统计
summary_stats = table(...
    [mean(results.total_cost)/conversion_factor; std(results.total_cost)/conversion_factor; ...
     min(results.total_cost)/conversion_factor; median(results.total_cost)/conversion_factor; ...
     max(results.total_cost)/conversion_factor], ...
    [mean(results.total_time); std(results.total_time); ...
     min(results.total_time); median(results.total_time); max(results.total_time)], ...
    [mean(results.rocket_cost ./ results.total_cost)*100; std(results.rocket_cost ./ results.total_cost)*100; ...
     min(results.rocket_cost ./ results.total_cost)*100; median(results.rocket_cost ./ results.total_cost)*100; ...
     max(results.rocket_cost ./ results.total_cost)*100], ...
    'VariableNames', {'TotalCost_TrillionUSD', 'TotalTime_Year', 'RocketCostRatio_Percent'}, ...
    'RowNames', {'Mean', 'Std', 'Min', 'Median', 'Max'});

summary_filename = 'simulation_summary_v3.csv';
writetable(summary_stats, summary_filename, 'WriteRowNames', true);
fprintf('汇总统计已保存: %s\n', summary_filename);

% 保存工作空间
save('complete_simulation_workspace_v3.mat', 'results', 'W0', 'num_simulations', ...
    'lambda_elevator', 'elevator_weibull_params', 'rocket_weibull_params', ...
    'conversion_factor');
fprintf('工作空间已保存: complete_simulation_workspace_v3.mat\n');

% 生成文本报告
report_filename = 'simulation_report_v3.txt';
fid = fopen(report_filename, 'w');
fprintf(fid, '火箭与太空电梯运输方案模拟报告 v3.0\n');
fprintf(fid, '生成时间: %s\n\n', datetime('now'));
fprintf(fid, '一、模拟概况\n');
fprintf(fid, '===========\n');
fprintf(fid, '模拟次数: %d\n', num_simulations);
fprintf(fid, '总运输量: %.0f 吨 (1亿吨)\n', W0);
fprintf(fid, '运行时间: %.1f 分钟\n\n', total_run_time/60);

fprintf(fid, '二、关键参数设置\n');
fprintf(fid, '===============\n');
fprintf(fid, '电梯故障频率 λ: %.3f (平均每%.1f年一次故障)\n', lambda_elevator, 1/lambda_elevator);
fprintf(fid, '电梯长延误概率 α: %.3f\n', elevator_weibull_params.alpha);
fprintf(fid, '火箭短延误概率 α: %.3f\n', rocket_weibull_params.alpha);
fprintf(fid, '电梯故障成本上限: %.0f 万美元 (三座电梯重建成本)\n\n', 51750000);

fprintf(fid, '三、主要结果\n');
fprintf(fid, '===========\n');
fprintf(fid, '平均总成本: %.2f 万亿美元\n', mean(results.total_cost)/conversion_factor);
fprintf(fid, '平均总时间: %.1f 年\n', mean(results.total_time));
fprintf(fid, '时间在180-550年内比例: %.1f%%\n', sum(results.total_time >= 180 & results.total_time <= 550)/num_simulations*100);
fprintf(fid, '火箭成本占比: %.1f%%\n', mean(results.rocket_cost ./ results.total_cost)*100);
fprintf(fid, '火箭运输量占比: %.1f%%\n', mean(results.rocket_weight / W0)*100);
fprintf(fid, '平均电梯故障次数: %.2f 次\n', mean(results.elevator_faults));
fprintf(fid, '平均火箭故障次数: %.2f 次\n\n', mean(results.rocket_faults));

fprintf(fid, '四、优化建议\n');
fprintf(fid, '===========\n');
if mean(results.total_time) < 180
    fprintf(fid, '当前平均时间低于目标下限，建议略微增加故障频率。\n');
    fprintf(fid, '建议将λ从%.3f调整到%.3f左右。\n', lambda_elevator, lambda_elevator*1.5);
elseif mean(results.total_time) > 550
    fprintf(fid, '当前平均时间超过目标上限，建议进一步降低故障频率。\n');
    fprintf(fid, '建议将λ从%.3f调整到%.3f左右。\n', lambda_elevator, lambda_elevator*0.7);
else
    fprintf(fid, '当前参数设置合理，平均时间在目标范围内。\n');
end

if mean(results.rocket_cost ./ results.total_cost) > 0.6
    fprintf(fid, '火箭成本占比较高，可考虑适当增加电梯使用比例。\n');
elseif mean(results.rocket_cost ./ results.total_cost) < 0.4
    fprintf(fid, '电梯成本占比较高，可考虑适当增加火箭使用比例。\n');
end

fprintf(fid, '\n五、图表说明\n');
fprintf(fid, '===========\n');
fprintf(fid, '共生成8个专业图表：\n');
fprintf(fid, '1. 成本-时间关系图：核心分布图，含目标范围\n');
fprintf(fid, '2. 成本构成分析图：占比分布、箱线图、关系图\n');
fprintf(fid, '3. 时间分布分析图：直方图、时间关系、构成图\n');
fprintf(fid, '4. 运输量分配分析图：分配关系、占比分布\n');
fprintf(fid, '5. 收敛性分析图：成本和时间收敛趋势\n');
fprintf(fid, '6. 相关性分析图：关键变量相关系数矩阵\n');
fprintf(fid, '7. Pareto前沿分析图：非支配解集\n');
fprintf(fid, '8. 方案类型与灵敏度分析图\n');

fclose(fid);
fprintf('文本报告已保存: %s\n\n', report_filename);

%% ============================================================================
% 第八部分：辅助函数与结束
% ============================================================================

% 辅助函数：条件判断
function result = ifelse(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end

% 显示完成信息
fprintf('=============================================\n');
fprintf('模拟分析完成！\n');
fprintf('已生成 8 个专业图表\n');
fprintf('已保存 3 个数据文件\n');
fprintf('已生成 1 份详细报告\n');
fprintf('总运行时间: %.1f 分钟\n', toc(start_time)/60);
fprintf('=============================================\n');