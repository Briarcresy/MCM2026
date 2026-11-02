# 历史材料归档

此目录保留竞赛期间的版本与推导过程。主要阅读入口是 [Q1](../code/q1_tradeoff.m)、[Q2](../code/q2_robustness.m) 和[主论文](../paper/paper.tex)。归档文件保留原内容，未经本次数值验证，不能直接当作当前模型依据。

## 文件迁移索引

| 原路径 | 整理后路径 | 用途 |
| --- | --- | --- |
| `Fixed_Final_Solution_to_Question_1_c.m` | [code/q1_tradeoff.m](../code/q1_tradeoff.m) | Q1 主要入口 |
| `Final_Solution_To_Q2.m` | [code/q2_robustness.m](../code/q2_robustness.m) | Q2 主要入口 |
| `Final_Solution_to_Question_1_c.m` | [code/Final_Solution_to_Question_1_c.m](code/Final_Solution_to_Question_1_c.m) | Q1 较早版本，约束不同 |
| `Solution_To_Q2.m` | [code/Solution_To_Q2.m](code/Solution_To_Q2.m) | Q2 v3.0；主入口为 v3.1 |
| `fit_small_dataset_6points.m` | [code/fit_small_dataset_6points.m](code/fit_small_dataset_6points.m) | 内置六点示例的非线性拟合 |
| `Linear_Fitness.m` | [code/Linear_Fitness.m](code/Linear_Fitness.m) | 调用上述拟合函数的辅助入口 |
| `paper/Q2.tex` | [paper/Q2.tex](paper/Q2.tex) | 独立 Q2 章节草稿 |
| `paper/Fixed_Q2.tex` | [paper/Fixed_Q2.tex](paper/Fixed_Q2.tex) | Q2 修订章节草稿 |
| 根目录成本笔记 | 下方 `notes/` 链接 | 参数推导的不同阶段 |
| 根目录竞赛指南 PDF | [docs/references/](../docs/references/) | 第三方参考材料 |
| 原 `README.md` 协作规则 | [docs/CONTRIBUTING.md](../docs/CONTRIBUTING.md) | 团队协作说明 |

## 参数推导笔记

- [b_Cost_Assumption.md](notes/b_Cost_Assumption.md)
- [b_Cost_Assumption_Final.md](notes/b_Cost_Assumption_Final.md)
- [b_Cost_and_Citation.md](notes/b_Cost_and_Citation.md)
- [Final_b_Cost_Assumption_and_Citation.md](notes/Final_b_Cost_Assumption_and_Citation.md)
- [Supreme_Final_b_Cost_Assumption_and_Citation.md](notes/Supreme_Final_b_Cost_Assumption_and_Citation.md)
- [Money_and_Time_Cost.md](notes/Money_and_Time_Cost.md)

文件名中的 “Final” 和 “Supreme” 是竞赛期间的命名，未据此确定笔记的学术准确性。六点拟合脚本明确写明使用示例数据，不作为经过核验的发射历史数据集。

归档 LaTeX 章节保留原图片路径，未适配新目录；它们用于阅读与追溯，不属于当前论文的编译依赖。
