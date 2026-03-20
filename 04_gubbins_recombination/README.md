# 04 – Recombination analysis (Gubbins)

This step runs Gubbins on `core.full.aln` to detect and mask recombination.

Example command:

```bash
micromamba activate gubbins_env
cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo/alignments

nohup run_gubbins.py \
  --prefix gubbins_fast \
  --threads 24 \
  --tree-builder fasttree \
  core.full.aln \
  > gubbins_fast.log 2>&1 &
```

What happens here is:

Gubbins filters out highly missing sequences and ran Multiple FastTree iterations
But FastTree hit a known bipartition mismatch bug:

```"This is a known issue when using FastTree to fit a phylogenetic model; use an alternative algorithm".```

Gubbins restarted but ultimately did not finish, so I switched tree builders.

```bash
micromamba activate gubbins_env
cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo/alignments

nohup run_gubbins.py \
  --prefix gubbins_raxml \
  --threads 24 \
  --tree-builder raxml \
  core.full.reduced.aln \
  > gubbins_raxml.log 2>&1 &
```
This ran succssfully and log ended with:


```textChecking for convergence...
...done. Run time: 95620.51 s
Maximum number of iterations (5) reached.

Exiting the main loop.

Creating the final output...
...finished. Total run time: 95623.35 s
```

Here are the outputs:
```bash
ls
gubbins_raxml.final_tree.tre
gubbins_raxml.node_labelled.final_tree.tre
gubbins_raxml.filtered_polymorphic_sites.fasta
gubbins_raxml.filtered_polymorphic_sites.phylip
gubbins_raxml.recombination_predictions.gff
gubbins_raxml.branch_base_reconstruction.embl
gubbins_raxml.per_branch_statistics.csv
gubbins_raxml.summary_of_snp_distribution.vcf
...
```

- Gubbins iteratively builds tree from SNP sites (RAxML).
- It fits a model, detects recombination(clusters of SNPs inconsistent with the tree).
- Masks recombinant regions and repeats.

- After convergence (or maximum iterations), it outputs:
    - **Recombination-filtered SNP alignment**: `gubbins_raxml.filtered_polymorphic_sites.fasta`.
    - **Final recombination-aware tree**: `gubbins_raxml.final_tree.tre`.
    - Annotations of recombination events on branches (GFF/EMBL).

This alignment is used to derive the core SNP alignment for the final phylogeny.



## Why Gubbins?

I picked Gubbins because I did not want recombination to mislead my tree.
Gubbins:
- iteratively builds trees and detects recombination on branches
- masks recombinant regions
- outputs a recombination-filtered alignment for SNP-based phylogeny

This helped me separate vertical signal (true clonal history) from
horizontal recombination, which is important for *Brucella*.
