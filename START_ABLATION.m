% Click Run to repeat MOHOA and its four ablations on all 22 problems.
releaseRoot=fileparts(mfilename('fullpath'));
addpath(fullfile(releaseRoot,'code'));
public_release.run(releaseRoot,'ablation');
