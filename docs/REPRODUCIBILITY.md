# 运行与复现说明

## 环境

本项目主要使用 MATLAB。当前环境未安装 MATLAB 或 GNU Octave，本次整理只检查了文件、引用与版本对应关系，没有完成数值运行验证。

| 入口 | 依赖 | 说明 |
| --- | --- | --- |
| `code/q1_tradeoff.m` | MATLAB、Optimization Toolbox | 使用 `fmincon`，默认采样 500,000 个点 |
| `code/q2_robustness.m` | MATLAB、Statistics and Machine Learning Toolbox | 使用 `poissrnd`、`wblrnd`、`boxplot` 等，默认模拟 100,000 次 |
| `paper/paper.tex` | TeX Live 或 MiKTeX、`mcmthesis` 及源文件所列宏包 | 必须从 `paper/` 目录编译，以解析 `../figure/` 路径 |

Q2 在脚本中间定义局部函数，因此建议使用 MATLAB R2024a 或更新版本。旧版本需要调整局部函数位置；本次整理保留了原始代码结构。GNU Octave 兼容性未经验证。

## MATLAB 运行

先将 MATLAB 当前文件夹设为仓库根目录。以下代码把模型目录加入搜索路径，并将生成文件写入 `outputs/`，避免混入源文件：

```matlab
project_root = pwd;
addpath(fullfile(project_root, 'code'));
if ~isfolder(fullfile(project_root, 'outputs'))
    mkdir(fullfile(project_root, 'outputs'));
end
cd(fullfile(project_root, 'outputs'));
q1_tradeoff
```

Q1 完成后可直接执行：

```matlab
q2_robustness
```

两个入口都会执行 `clear; clc; close all;`，会清空当前工作区与图窗。使用脚本名称调用即可；MATLAB 的 `run('/path/to/script.m')` 可能临时切换目录，使输出位置与上述说明不同。

回到仓库时，在 MATLAB 文件浏览器中选择仓库目录即可；脚本已清除运行前定义的 `project_root` 变量。

## 随机性与运行规模

- Q1 原脚本未设置随机种子。如需可重复采样，在每次调用前执行 `rng(2024, 'twister'); q1_tradeoff`；`clear` 不会重置随机数生成器。
- Q2 内部固定使用 `rng(2024, 'twister')`。修改外部种子不会覆盖它。
- Q1 的 Pareto 筛选与 Q2 的双重循环具有较高计算成本，最坏情况下接近平方复杂度。默认规模不适合快速冒烟验证。
- 若只需检查依赖和绘图，可以在本地副本中把 Q1 的 `n_samples` 改为 `5000`、Q2 的 `num_simulations` 改为 `1000`。Q2 进度间隔为模拟次数除以 50，建议采用 50 的整数倍。缩小规模得到的结果不能用来验证论文数值。

## 输出

Q1 在命令窗口输出可行解、Pareto 分析与推荐方案，并打开图窗，未自动保存图像。

Q2 打开多组图窗，并在当前工作目录生成：

| 文件 | 内容 |
| --- | --- |
| `complete_simulation_results_v3.csv` | 每次模拟的详细结果 |
| `simulation_summary_v3.csv` | 汇总统计 |
| `complete_simulation_workspace_v3.mat` | 模拟结果与部分参数 |
| `simulation_report_v3.txt` | 文本报告 |

`outputs/` 被 Git 忽略。现有 `figure/` 中的图片为原仓库保留材料，运行脚本不会自动覆盖或完整重建这些图片。

## 论文编译

在终端的仓库根目录执行：

```bash
cd paper
latexmk -xelatex -interaction=nonstopmode -halt-on-error paper.tex
```

仓库已包含可直接查看的[论文 PDF](../paper/paper.pdf)（27 页，含 AI 使用报告），并在 README 提供摘要页预览。展示版由 XeLaTeX 编译，已检查页面显示；正文模型与结果未改动，仅修复字符兼容、表格排版及多余字符。

上述命令可重新生成 `paper/paper.pdf`。主论文是独立文件，不需要编译归档章节。AI 使用报告可另外执行 `latexmk -xelatex AIreport.tex`。

如果缺少 `mcmthesis.cls` 或宏包，请通过 TeX 发行版安装相应组件。编译产物不会自动提交；若后续整理出经过核对的展示版 PDF，可显式添加到 `paper/`，`.gitignore` 已为该目录的 PDF 保留例外，其余 LaTeX 中间文件仍被忽略。

## 复现范围

目前能够定位两个主要模型及其输入参数；输入均写在脚本内，没有外部数据下载步骤。论文中水资源循环、碳价和可再生能源敏感性图没有相应的独立生成脚本，因此尚不能一键重建整篇报告。详细限制见[模型说明](MODELS.md)。
