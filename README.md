# MOHOA for multi-objective flexible job shop scheduling

Code and numerical data for **Multi-objective Flexible Job Shop Scheduling Optimization Considering Makespan Machine Load and Energy Consumption** by Wenzhuo Meng and Yuanbin Mo.

The study minimizes makespan, total machine workload, and energy consumption. MOHOA generates one offspring per parent: Cauchy mutation with probability 0.70, otherwise a hiking update. The leader is sampled from the current first nondominated front and held fixed during that iteration.

## Contents

| Path | Contents |
|---|---|
| `code/algorithms/functions/` | Separate benchmark-function implementations of the seven compared methods |
| `code/algorithms/fjsp/` | Corresponding FJSP implementations |
| `code/addons/HSGA/` | Paper-based HSGA adaptation for FJSP |
| `code/common/` and `code/+study/` | Objective functions, FJSP decoder, population utilities, and metrics |
| `code/vendor/PlatEMO/` | Native MOEA/D and the small set of platform dependencies it uses |
| `code/data/Brandimarte_Data/` | Exact MK01–MK10 instance files used in the experiments |
| `data/per_run.csv` | All 2,520 retained runs: seeds, elapsed times, IGD and HV |
| `data/final_objectives/` | Full final objective matrices from every retained run, as MATLAB MAT files |
| `data/reference_fronts/` | Exact sampled/empirical reference sets and normalization bounds |
| `data/power_parameters.csv` | Processing and idle powers for machines 1–15 |
| `data/tables/` | Statistical results, runtime data, representative-run selections, plot points, and MK10 schedules |
| `data/MK10_MOHOA_decisions.mat` | All ten final MOHOA decision matrices on MK10 |
| `analysis/rebuild_tables.py` | Offline metric verification, tables, statistical tests and plots from saved data |
| `docs/` | Protocol, data dictionary, implementation provenance and change records |

The archive contains 1,320 benchmark-function runs and 1,200 MK runs, including the four MOHOA ablations and 100 HSGA runs. All use ten repeats and 200 iterations.

## Use the saved results without running experiments

Open this folder in MATLAB and click **Run** on `VIEW_SAVED_RESULTS.m`. It displays the summary and opens example saved fronts and the three MK10 Gantt charts. This script does not run an optimizer.

The CSV files can also be opened directly in Excel. `data/README.md` describes the fields and MAT-file naming. `analysis/rebuild_tables.py` can be run in a Python IDE with the packages listed in `analysis/requirements.txt`; its output goes into `generated/`. It reads only the supplied saved results.

## Repeat the optimization experiments

MATLAB R2024a with Statistics and Machine Learning Toolbox was used. The retained implementations call functions including `pdist2`, `unifrnd` and `randsample`; these have not been replaced with different operators. The reported experiments were serial, on 64-bit Windows, Intel Core i7-14700HX and 16 GB RAM.

Open this folder in MATLAB and click **Run** on the desired script:

| Script | Tasks |
|---|---|
| `START_FUNCTIONS.m` | Seven main methods on all twelve ZDT/DTLZ problems |
| `START_FJSP.m` | The same seven methods on MK01–MK10 |
| `START_ABLATION.m` | MOHOA and its four variants on all 22 problems |
| `START_HSGA.m` | HSGA adaptation on MK01–MK10 only |

Fresh runs are saved in `rerun_results/`, separately from the immutable `data/` archive. Completed tasks are skipped after their source/configuration fingerprint is checked. Scripts are serial. Whole experiments can take substantial time; viewing/rebuilding the saved data is sufficient to inspect the paper results.

The release launchers are new packaging interfaces. Existing algorithm functions, helper files and the FJSP evaluator were copied without changes. `config_study.m` changes only the list of included methods; population settings, iteration counts, operators and power values are retained. Historical seed indices are explicitly preserved. See `docs/PACKAGING_CHANGES.md`.

## Interpretation

- The raw FJSP objective columns are **makespan, energy, total workload**, in that order. They are not ordered as in the manuscript's verbal list.
- Power values are **specified by the authors**, rather than measured equipment data. One benchmark time unit is interpreted as one hour for reporting. Used machines remain on from zero to completion of their last assigned operation; unused machines remain off. Startup/shutdown energy is excluded.
- Normalization uses shared bounds from the saved reference set, without clipping. HV uses `(1, 1)` or `(1, 1, 1)`. MK references pool all eight main methods and four ablations, not NSGA-II.
- The configured population is 100. Native PlatEMO MOEA/D uses 100 members for two objectives and 91 for three objectives; its weight generation is retained.
- Runtime is the original serial whole-call wall-clock time. Seconds per iteration is that value divided by 200 and includes amortized initialization and history storage.
- HSGA is a **paper-based adaptation**, not official author code. Its changed objective and fixed reproduction conventions are disclosed in `docs/HSGA_SOURCE_AND_ASSUMPTIONS.md`.

## Sources and citation

See `THIRD_PARTY_NOTICES.md` for implementation sources, retained notices and required acknowledgments. The native MOEA/D subset comes from [PlatEMO](https://github.com/BIMK/PlatEMO/tree/d25e65d1ffba58dbf4d7e1b5259786187d12968a). NSGA-III is the [Yarpiz YPEA126 implementation](https://yarpiz.com/456/ypea126-nsga3), adapted to the common problem interface. No repository-wide license is imposed on third-party code; see `LICENSE_SCOPE.md`.

`CITATION.cff` identifies this code/data collection without inventing a publication DOI or repository URL. Please also cite the underlying algorithms and datasets as appropriate. File checksums are in `SHA256SUMS.txt`.
