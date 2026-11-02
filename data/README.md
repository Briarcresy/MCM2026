# 数据说明

两个主要 MATLAB 模型的输入参数均直接定义在脚本中，当前不读取外部数据文件。

- [Q1 参数](../code/q1_tradeoff.m)：工期与成本边界、约束、采样数量。
- [Q2 参数](../code/q2_robustness.m)：运输能力、成本、故障概率、延误分布及模拟数量。
- [历史拟合示例](../archive/code/fit_small_dataset_6points.m)：内置六点示例数据，未经核验为真实观测数据。

模拟生成的 CSV、MAT 和文本报告写入 `outputs/`（按[运行指南](../docs/REPRODUCIBILITY.md)操作），不作为原始输入提交。

论文中的参考文献见 [paper.tex](../paper/paper.tex) 文末；原始数据采集快照与完整数据处理流程未随仓库提供。
