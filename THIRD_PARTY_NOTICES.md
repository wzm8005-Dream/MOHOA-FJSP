# Sources and third-party notices

## Actual implementation provenance

| Material | Implementation used in this study | Source |
|---|---|---|
| MOHOA | Study implementation with the disclosed components | `code/algorithms/`; helper headers retained |
| MOPSO | Author-supplied project version bearing Víctor Martínez Cagigal's 2017 header | [MATLAB File Exchange MOPSO](https://www.mathworks.com/matlabcentral/fileexchange/62074-multi-objective-particle-swarm-optimization-mopso); `licenses/MOPSO_BSD.txt` |
| MODA | Author-supplied project version bearing Seyedali Mirjalili's header | [Dragonfly paper](https://doi.org/10.1007/s00521-015-1920-1); [author site](https://www.alimirjalili.com/DA.html) |
| MOGOA | Author-supplied project version bearing the grasshopper-code source header | [multi-objective grasshopper paper](https://doi.org/10.1007/s10489-017-1019-8); [author site](https://www.alimirjalili.com/GOA.html) |
| MOMA | Retained author-supplied MATLAB project implementation, with the existing search and archive rules | Original uploaded project; no independently verified versioned upstream repository is asserted |
| NSGA-III | Yarpiz YPEA126 by S. Mostapha Kalami Heris, 2016; common-interface and documented shape/boundary adaptations | [implementation page](https://yarpiz.com/456/ypea126-nsga3); `licenses/NSGA3_BSD.txt` |
| MOEA/D | Unchanged native `MOEAD.m`, PBI default, platform operators and weight generation | [BIMK/PlatEMO pinned commit](https://github.com/BIMK/PlatEMO/tree/d25e65d1ffba58dbf4d7e1b5259786187d12968a) |
| HSGA | New paper-based MATLAB adaptation; not official author source | [Hao, Zou and Liang, DOI](https://doi.org/10.1016/j.cie.2024.110829); conventions in `docs/HSGA_SOURCE_AND_ASSUMPTIONS.md` |
| MK instances | Exact Brandimarte files from the supplied experimental project | [Brandimarte 1993](https://doi.org/10.1007/BF02023073); [FJSPLib](https://scheduleopt.github.io/benchmarks/fjsplib) |

A link to a paper or source site is provenance, not a claim that an adapted local implementation is byte-identical to a currently downloadable version. Full local-to-package copy hashes are in `docs/source_copy_manifest.csv`.

## PlatEMO acknowledgment

The included PlatEMO files retain their original copyright notices. Publications using the platform or its code should acknowledge PlatEMO and cite: Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin. PlatEMO: A MATLAB Platform for Evolutionary Multi-Objective Optimization. IEEE Computational Intelligence Magazine, 2017, 12(4), 73–87. https://doi.org/10.1109/MCI.2017.2742868 . The upstream terms, rather than a new license written for this study, govern these files.

## Adaptation records

Baseline main functions were connected to a shared problem interface; non-search display/metric code was removed. Historical archive-shape, odd-dimension, NSGA-III interface and mutation-shape fixes are documented in `docs/`. This package does not introduce new search operators or performance tuning for the compared algorithms. The common FJSP evaluator and decoder retain their original bytes. These study adaptations must be disclosed rather than described as unmodified original author implementations.
