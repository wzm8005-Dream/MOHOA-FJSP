% Click Run to repeat the seven main methods on MK01-MK10.
releaseRoot=fileparts(mfilename('fullpath'));
addpath(fullfile(releaseRoot,'code'));
public_release.run(releaseRoot,'fjsp');
