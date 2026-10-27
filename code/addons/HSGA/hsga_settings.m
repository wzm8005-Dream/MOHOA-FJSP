function s=hsga_settings()
% Paper-reported values and explicit, untuned reproduction conventions.
% This is NOT original author source code. See SOURCE_AND_ASSUMPTIONS.md.
s.Version='HSGA-paper-adaptation-v1';
s.Algorithm='HSGA_Paper';s.AlgorithmSeedIndex=13;
s.PaperDOI='10.1016/j.cie.2024.110829';
s.PaperSHA256='63325d68cbcfc17c6e8a7d190e99395001efe272c2fad32e5931b2716324694d';
% Paper Table 4 / equations (19)-(20).
s.CrossoverMax=.90;s.CrossoverMin=.75;
s.MutationMax=.20;s.MutationMin=.075;s.DensityRadius=.20;
% Table 3 reports weights summing to 0.8; preserve their relative proportions.
s.InitialWeights=[.20 .30 .30]; % GS, LS, RS; normalized before allocation.
s.KMeansRestarts=10; % Section 4.2.1 reports ten starting-center sets.
% Not fully reported in the paper: fixed conventions, NOT tuned on outcomes.
s.Clusters=3;s.KMeansMaxIterations=100;
s.POXProbability=.50;s.MutationGeneCount=2;
s.SparseParentCount=1;s.NeighborhoodPasses=1;
s.ChromosomeConvention='OS job sequence plus fixed job-operation-order MS indices';
s.EnvironmentalTieBreak='Non-dominated rank, then crowding distance';
s.Objectives={'Cmax','Energy','TotalWorkload'};
end
