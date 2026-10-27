% Click Run to repeat only the paper-based HSGA adaptation on MK01-MK10.
releaseRoot=fileparts(mfilename('fullpath'));
addpath(fullfile(releaseRoot,'code'));
public_release.run(releaseRoot,'hsga');
