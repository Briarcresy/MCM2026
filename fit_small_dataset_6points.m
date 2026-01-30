
function fit_small_dataset_6points()
    % 自定义函数拟合：N(t) = k*t + m - n/(t - t0)
    
    % ==================== 第一部分：数据准备 ====================
    % 这里假设您有6组数据，请替换为您的实际数据
    % t_data: 自变量数据 (6×1向量)
    % N_data: 因变量数据 (6×1向量)
    
    % 示例数据（请用您的实际数据替换这些）
    t_data = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]';  % 自变量，列向量
    N_data = [0.0, 2.0, 6.0, 8.0, 12.0, 17.0]';  % 因变量，列向量
    
    % ==================== 第二部分：参数初始值估计 ====================
    % 良好的初始值对非线性拟合很重要
    % 我们可以通过线性近似来获得初始值
    
    % 方法：当 t 远离 t0 时，n/(t-t0) 项的影响较小
    % 先进行线性拟合：N ≈ k*t + (m - n/t0) （近似）
    X = [t_data, ones(size(t_data))];
    coeff_linear = X \ N_data;
    k_init = coeff_linear(1);
    m_init = coeff_linear(2);
    
    % 对于 n 和 t0，我们可以尝试一些合理的初始值
    n_init = 1;  % 初始猜测值
    t0_init = min(t_data) - 1;  % 假设 t0 小于最小 t 值
    
    % 初始参数向量 [k, m, n, t0]
    params_init = [k_init, m_init, n_init, t0_init];
    
    % ==================== 第三部分：定义模型函数 ====================
    model_func = @(params, t) params(1)*t + params(2) - params(3)./(t - params(4));
    
    % ==================== 第四部分：设置拟合选项 ====================
    % 定义参数边界（根据实际情况调整）
    % [k_min, m_min, n_min, t0_min; k_max, m_max, n_max, t0_max]
    lb = [-Inf, -Inf, 0, min(t_data)-10];   % 下界
    ub = [Inf, Inf, Inf, min(t_data)-0.1];  % 上界，确保 t0 < min(t_data)
    
    % 设置拟合选项
    options = optimoptions('lsqcurvefit', ...
        'Display', 'iter', ...      % 显示迭代过程
        'MaxFunctionEvaluations', 1000, ...
        'MaxIterations', 400, ...
        'FunctionTolerance', 1e-10, ...
        'StepTolerance', 1e-10);
    
    % ==================== 第五部分：执行拟合 ====================
    fprintf('开始拟合...\n');
    fprintf('初始参数值: k=%.4f, m=%.4f, n=%.4f, t0=%.4f\n', ...
        params_init(1), params_init(2), params_init(3), params_init(4));
    
    try
        [params_opt, resnorm, residual, exitflag, output] = ...
            lsqcurvefit(model_func, params_init, t_data, N_data, lb, ub, options);
        
        fprintf('\n拟合完成!\n');
        fprintf('退出标志: %d\n', exitflag);
        fprintf('输出信息: %s\n', output.message);
        
    catch ME
        fprintf('拟合过程中出现错误: %s\n', ME.message);
        fprintf('尝试使用无边界约束的拟合...\n');
        
        % 如果带边界约束失败，尝试无边界约束
        [params_opt, resnorm, residual, exitflag, output] = ...
            lsqcurvefit(model_func, params_init, t_data, N_data, [], [], options);
    end
    
    % ==================== 第六部分：输出结果 ====================
    fprintf('\n========== 拟合结果 ==========\n');
    fprintf('最优参数值:\n');
    fprintf('k = %.6f\n', params_opt(1));
    fprintf('m = %.6f\n', params_opt(2));
    fprintf('n = %.6f\n', params_opt(3));
    fprintf('t0 = %.6f\n', params_opt(4));
    
    % 计算R²
    N_pred = model_func(params_opt, t_data);
    SSR = sum((N_pred - mean(N_data)).^2);
    SST = sum((N_data - mean(N_data)).^2);
    R_squared = SSR / SST;
    
    fprintf('残差平方和: %.6f\n', resnorm);
    fprintf('R²: %.6f\n', R_squared);
    
    % ==================== 第七部分：可视化结果 ====================
    figure('Position', [100, 100, 1200, 500]);
    
    % 子图1：拟合曲线与原始数据
    subplot(1, 2, 1);
    
    % 生成平滑曲线用于绘图
    t_fine = linspace(min(t_data), max(t_data), 100);
    % 确保 t_fine 中的值不等于 t0
    t_fine = t_fine(t_fine ~= params_opt(4));
    
    N_fine = model_func(params_opt, t_fine);
    
    % 绘制拟合曲线
    plot(t_fine, N_fine, 'b-', 'LineWidth', 2, 'DisplayName', '拟合曲线');
    hold on;
    
    % 绘制原始数据点
    plot(t_data, N_data, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
        'DisplayName', '原始数据');
    
    grid on;
    xlabel('t', 'FontSize', 12);
    ylabel('N(t)', 'FontSize', 12);
    title('自定义模型拟合结果', 'FontSize', 14);
    legend('Location', 'best');
    
    % 添加方程文本
    eq_text = sprintf('N(t) = %.4ft + %.4f - %.4f/(t - %.4f)', ...
        params_opt(1), params_opt(2), params_opt(3), params_opt(4));
    text(0.05, 0.95, eq_text, 'Units', 'normalized', ...
        'VerticalAlignment', 'top', 'FontSize', 10, ...
        'BackgroundColor', 'white');
    
    % 子图2：残差分析
    subplot(1, 2, 2);
    
    % 计算残差
    residuals = N_data - N_pred;
    
    % 绘制残差图
    scatter(t_data, residuals, 100, 'b', 'filled');
    hold on;
    plot([min(t_data), max(t_data)], [0, 0], 'r--', 'LineWidth', 2);
    
    grid on;
    xlabel('t', 'FontSize', 12);
    ylabel('残差', 'FontSize', 12);
    title('残差分析图', 'FontSize', 14);
    
    % 添加统计信息
    mean_resid = mean(residuals);
    std_resid = std(residuals);
    text(0.05, 0.95, sprintf('残差均值: %.4f\n残差标准差: %.4f', ...
        mean_resid, std_resid), 'Units', 'normalized', ...
        'VerticalAlignment', 'top', 'FontSize', 10, ...
        'BackgroundColor', 'white');
    
    % ==================== 第八部分：预测和评估 ====================
    fprintf('\n========== 预测值比较 ==========\n');
    fprintf('t\t实际值\t预测值\t残差\t相对误差(%%)\n');
    fprintf('----------------------------------------\n');
    
    for i = 1:length(t_data)
        actual = N_data(i);
        predicted = N_pred(i);
        resid = actual - predicted;
        rel_error = abs(resid/actual)*100;
        fprintf('%.2f\t%.4f\t%.4f\t%.4f\t%.2f\n', ...
            t_data(i), actual, predicted, resid, rel_error);
    end
    
    % ==================== 第九部分：保存结果 ====================
    % 保存拟合参数到文件
    results.k = params_opt(1);
    results.m = params_opt(2);
    results.n = params_opt(3);
    results.t0 = params_opt(4);
    results.R_squared = R_squared;
    results.resnorm = resnorm;
    results.t_data = t_data;
    results.N_data = N_data;
    results.N_pred = N_pred;
    results.residuals = residuals;
    
    save('fitting_results.mat', 'results');
    fprintf('\n结果已保存到 fitting_results.mat\n');
    
end