# Source and disclosed reproduction conventions

## Source

Hao, L.; Zou, Z.; Liang, X. Solving multi-objective energy-saving flexible job shop scheduling problem by hybrid search genetic algorithm. *Computers & Industrial Engineering* **200** (2025), 110829.

- DOI: https://doi.org/10.1016/j.cie.2024.110829
- Publisher: https://www.sciencedirect.com/science/article/pii/S0360835224009513
- Implementation basis: the 16-page PDF supplied by the user; algorithm pages 5–10 were checked in text and rendered views.
- Supplied PDF SHA-256: `63325d68cbcfc17c6e8a7d190e99395001efe272c2fad32e5931b2716324694d`.
- The paper reports a Python implementation (Section 5.1). This add-on is a new MATLAB implementation, **not the authors' source**.
- No verifiable public author repository was located in the publisher entry, attached paper, or title/author/DOI searches as of 25 October 2026. This search result is not proof that no repository exists.

## Published objective mismatch

The paper minimizes makespan, maximum machine workload, and total machine workload. This project minimizes **makespan, energy, and total machine workload**. The reproduced search operators use the existing project objective evaluator for selection, sparse-density filtering, and all comparisons. The maximum-workload objective is replaced by the project's energy objective. No claims are made that these results reproduce the original paper's objective values or rankings.

The original project's synthetic power parameters, machine on/off accounting window, processing times, machine eligibility, and objectives are unchanged. Published HSGA initialization and STS operators continue to use processing time/load, not an added energy-aware heuristic.

## Paper-to-implementation map

| Paper location | Implemented behavior |
|---|---|
| Sections 4.2.1–4.2.2 | K-means clustering of normalized chromosome features; choose each mating pair from two distinct randomly chosen clusters; ten starting-center sets; keep the lowest within-cluster squared-error solution |
| Section 4.2.3 | Discrete job-sequence OS and machine-choice MS; random OS with correct job counts; GS, LS and RS machine initialization; earliest feasible insertion decoder |
| Equation (17) | Objective-wise min-max normalization for density; a constant objective has denominator1 |
| Equation (18), Algorithm2 | Count other solutions within radius0.2; divide by population size minus1; select a minimum-density parent |
| Section 4.4 | One pass over DSS+STS, EIS+STS, SRS+STS; DSS swaps two OS positions, EIS inserts the first after the second, SRS reverses an interval; STS assigns selected operations to shortest-processing-time eligible machines |
| Equations (19)–(20) | Linear schedules from crossover0.90 to0.75 and mutation0.20 to0.075 using generation/maximum generations |
| Section 4.5.2 | POX/JOX OS crossover, binary-mask MS crossover, OS position exchanges, shortest-processing-time MS mutation |
| Algorithm3 | Cluster mating pool; sparse-parent neighborhood generation; neighborhood non-dominated front; combine with mating pool and truncate; adaptive crossover/mutation; evaluate next generation |

No external best-so-far archive, extra post-crossover parent-offspring elitism, extra neighborhood depth, or performance-based tuning is added. In particular, the environmental truncation is **before** crossover/mutation as stated in Algorithm3; the next population is not silently replaced by an elitist parent-plus-child union afterwards.

## Incomplete or inconsistent details and fixed conventions

These are implementation choices needed to make the paper executable, **not parameters claimed to have been reported by the authors**. They are saved in every run and are not tuned after examining performance.

1. **Cluster count.** No final numerical K is reported. Use K=3, matching the illustrative cluster count in Figure2; do not claim it is an experimentally optimized setting.
2. **K-means stopping and normalization.** Use chromosome-column min-max scaling, k-means++ distance-squared seeding, ten restarts, maximum100 Lloyd iterations per restart, and stop earlier if assignments stop changing. Empty clusters use singleton reassignment from the farthest eligible point. These details complete the paper's general distance-based initialization/update description.
3. **Initialization weights.** The stated GS/LS/RS settings are0.20/0.30/0.30, which sum to0.80. Normalize those weights, preserve their relative proportions, and use largest-remainder integer allocation. N=100 gives25GS,38LS,37RS individuals. Do not silently relabel the paper's RS value as0.50.
4. **GS/LS ties and visitation.** GS visits jobs in a random permutation, maintaining loads across jobs; LS resets loads for each job. Both minimize current load plus processing time and use random tie breaking. RS chooses a uniformly random eligible-machine index.
5. **POX versus JOX.** The switching threshold is not numerically reported; set it to0.50. POX preserves the same job subset from each corresponding parent and fills remaining jobs from the other parent. JOX preserves complementary subsets in the two children. Subsets are nonempty and proper.
6. **Mutation size.** The paper uses an unspecified r. Set r=2 distinct positions for OS exchanges and for MS shortest-time mutation. One mutation-probability gate per offspring controls both layers. Ties among shortest-time machines are random.
7. **Sparse-parent count and VNS depth.** Algorithm2 returns one minimum-density index. Use one such parent, with uniform random selection among ties, and one pass over all three combined neighborhoods. Each neighborhood is independently generated from the same sparse parent. No repeated improvement-until-local-optimum loop is invented.
8. **Density boundary.** Use distance≤R, following Algorithm2. Exclude the individual itself, consistent with the N−1 denominator in Equation(18).
9. **Algorithm3 self-reference.** Its line6 filters an as-yet undefined P''; use the available cluster-selected P' as described by the surrounding text. This correction is documented rather than silently claimed to be original author code.
10. **Truncation of a partial front.** The paper mentions non-dominated sorting without specifying a fixed-size tie rule. Use ordinary crowding distance for the partial front. No NSGA-III reference-point selection is added to HSGA.
11. **OS/MS alignment.** Use a fixed job-operation index for MS genes so that machine eligibility is invariant under OS crossover. Figure3's sequence-aligned illustration and the text do not specify how MS is repaired after changing OS; this is an explicit representation convention and adaptation, not a claim of exact author implementation equivalence. Both OS and MS search operators remain discrete.
12. **Generation count.** The paper's Table4 uses100 generations. The project uses200 generations and10 independent repeats; these shared project settings are retained. Generation indices1…200 are used in Equations(19)–(20). No Taguchi parameter search is rerun.

## Lossless interface to the existing model

The common decoder uses inverse ranks of the OS keys. For each discrete OS, assign each job occurrence a distinct rank from that job's block in the base job sequence. Encode those ranks as strictly ordered keys in (−n,n). Thus the existing inverse-rank decoder returns exactly the intended job sequence. Each MS index is mapped to the continuous value at its integer center under the existing affine rounding rule; singleton choices use0.

This bridge is used only for common evaluation and saved X vectors. It does not replace HSGA's discrete search with continuous mutation. Every returned final objective vector is checked against evaluation of the saved X using the original model, just as for the original algorithms.

## Reporting scope

Use the name **HSGA_Paper** or **paper-based HSGA adaptation** in internal results. A manuscript must disclose the changed objective and the choices above; it must not call this an unmodified official implementation. If author code becomes available, an equivalence audit is needed before treating results from the two implementations as interchangeable.
