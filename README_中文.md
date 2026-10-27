# 上传与使用说明

这是与返修论文对应的精简代码和数据版本。上传时，将本文件所在目录中的文件和文件夹放到 GitHub 仓库根目录，保持层级；不要只上传整个 ZIP 文件，否则网页不能直接浏览源码和数据。

建议仓库名：`MOHOA-FJSP`。

若使用 GitHub 网页上传，可使用另附的“网页分批上传包”：解压后按 01–05 顺序，每次进入一个批次目录，将**里面的文件或文件夹**拖入仓库根目录。不要把 01–05 批次目录本身传到仓库里；各批次中的 `code` 文件夹会按路径合并。这样每批文件数都不超过网页的 100 文件限制。说明来源：[GitHub 官方上传说明](https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository)。

建议简介：`MATLAB implementations and experimental data for multi-objective hiking optimization of flexible job shop scheduling.`

## 保留内容

- MOHOA、MOPSO、NSGA-III、MODA、MOGOA、MOMA、MOEA/D 的测试函数和 FJSP 版本，以及 HSGA 论文复现适配版。
- 公共评价函数、FJSP 解码器、标准 DTLZ6、MK01–MK10 原始实例和实际使用的功率参数。
- 2,520 次运行的最终目标矩阵、随机种子、耗时、IGD/HV、参考集和归一化范围。
- 统计性检验、双向 C 指标、消融、运行时间、最优已知 makespan 比较和画图数据。
- MK10 甘特图的工序数据、机器时间数据，以及 MOHOA 十次运行的最终决策矩阵。

不包含旧 NSGA-II、未调用的平台算法、Word 稿件、审稿信、个人本机路径、会话日志和所有代的完整历史。最终目标矩阵保留原有行，不以均值或少量最好结果替代；统计分析时再取唯一非支配集。

## 不跑实验查看结果

在 MATLAB 打开仓库目录，打开 `VIEW_SAVED_RESULTS.m`，点击“运行”，可看结果表、示例前沿图和 MK10 的三幅甘特图。不会调用优化算法。

表格和画图数据在 `data/tables/`，可直接用 Excel 查看。`data/per_run.csv` 是完整逐次指标数据。Python 的离线重建脚本可在 IDE 中运行，不涉及优化实验；所需库见 `analysis/requirements.txt`。

## 如需复现实验

点击 `START_FUNCTIONS.m`、`START_FJSP.m`、`START_ABLATION.m` 或 `START_HSGA.m`。均为原来的串行配置，每种方法每个问题重复 10 次、迭代 200 次。重新运行的数据单独保存到 `rerun_results/`，不覆盖本次公开的数据。

搜索算法及解码器没有因本次打包而修改。为了移除 NSGA-II，公开配置只调整算法名单；其余算法仍沿用原来的种子编号，具体种子已全部列出。MOEA/D 三目标原生个体数为 91，保留原权重生成方式。HSGA 的适配约定单独公开。

## 上传后

复制实际仓库网址，用于论文的 Data Availability Statement 和回复信。只有上传后，才能将回复中的“计划公开”改成“已公开”。包内没有替你生成虚假的仓库地址或发表 DOI。可在 GitHub 创建一个 Release 固定本次版本，便于之后论文引用。

许可范围和第三方来源见 `LICENSE_SCOPE.md` 和 `THIRD_PARTY_NOTICES.md`；保留原版权说明，不把第三方代码统一改成自己的许可证。
