function cfg=config_study()
cfg.Version='rebuild-10x200-v2';
cfg.Algorithms={'MOHOA','MOPSO','NSGA3','MODA','MOGOA','MOMA','MOEAD'};
cfg.Ablations={'MOHOA_NoGPS','MOHOA_NoCauchy','MOHOA_Crowding','MOHOA_Base'};
cfg.Problems=[{'ZDT1','ZDT2','ZDT3','ZDT4','ZDT6'},arrayfun(@(i)sprintf('DTLZ%d',i),1:7,'UniformOutput',false),arrayfun(@(i)sprintf('Mk%02d',i),1:10,'UniformOutput',false)];
cfg.Population=100;cfg.Iterations=200;cfg.Repeats=10;
cfg.MutationProbability=.70;cfg.SeedBase=20261021;
cfg.HVReference=1; % Same normalized reference coordinate in every objective.
cfg.Energy.work=[1.65 1.50 2.25 1.66 .80 1.45 1.88 .62 1.76 1.54 1.20 1.14 2.50 1.29 1.77 2.18 .90 2 2.50 1.80];
cfg.Energy.spare=[.12 .25 .10 .15 .25 .11 .20 .13 .22 .30 .20 .14 .26 .09 .13 .18 .10 .15 .14 .08];
cfg.Energy.cost=ones(1,20);
cfg.OutputGroup='';cfg.ReportCurvePoints=21;
end
