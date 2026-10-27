# Changes made for this public package

The source is the completed serial experimental project. Every included search implementation, its private helpers, shared objective evaluator, decoder, and native PlatEMO file is copied byte for byte. `source_copy_manifest.csv` records hashes of these copies.

The packaging changes are limited to:

1. Excluding the withdrawn NSGA-II implementation and unused PlatEMO algorithms, GUI and examples.
2. Reordering/removing method names in `code/config_study.m` to match the manuscript. Numeric configuration values are unchanged. New launchers use explicit **original** seed-slot indices, rather than taking indices from the shorter method list.
3. New launchers under `code/+public_release/` and at the repository root, saving fresh experiments into `rerun_results/`. They do not alter search operators, weights, decoding or stopping-generation settings.
4. Compactly exporting final objective matrices without changing their numeric values, together with the exact reference sets, final indicators and figure source tables. Read-back equality was checked for all 2,520 final matrices.
5. Adding offline result inspection and analysis scripts, documentation and checksums.

The original project includes interface and bug fixes made **before or during** the completed experiments. Those are not new changes in this packaging task: MOGOA odd-dimension evaluation adapter; archive-row shape handling; NSGA-III unit-cube/boundary interface and mutation-shape correction; corrected standard DTLZ6. Corresponding retained difference files are in this folder. These adaptations mean the study implementations should not be described as bitwise identical to unadapted upstream demo scripts.

No optimization experiment was executed while preparing this package. The original project, source archives, manuscript and saved results were not modified.
