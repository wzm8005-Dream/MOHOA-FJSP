# MOHOA for multi-objective flexible job shop scheduling

MATLAB code and key experimental data accompanying the revised manuscript.

- code/: MOHOA, comparison methods, shared scheduling decoder, and benchmark instances.
- data/: final objective vectors, per-run results, reference fronts, and table/plot data.
- code/START_EXAMPLE.m: click Run in MATLAB to execute one example.
- code/REBUILD_INDICATORS.m: reproduce final IGD/HV from the compact objective data.

MK objective columns are **makespan, energy, total workload**, in that order. Powers are author-defined. NSGA-III is the native PlatEMO implementation; HSGA is a paper-based adaptation. MATLAB with Statistics and Machine Learning Toolbox is required for the native dependencies.

Third-party notices remain in the source files; see NOTICE.md. Replace the previous code/data folders with this revision rather than mixing versions.
