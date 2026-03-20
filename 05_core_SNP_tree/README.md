# 05 – Core SNP alignment and final tree

Here we reduce the recombination-filtered alignment to core SNPs and infer the final ML tree.

Commands:


# Core SNP alignment
```bash
cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo/alignments

# Extract core SNP alignment (no invariant sites)
snp-sites -c gubbins_raxml.filtered_polymorphic_sites.fasta > core_snps_gubbins.aln

# Build ML tree with support
iqtree2 -s core_snps_gubbins.aln -m GTR+G -bb 1000 -alrt 1000 -nt AUTO
```


Important outputs:
Outputs:

- `core_snps_gubbins.aln.treefile` – ML core SNP tree (branch lengths on recombination‑cleaned SNPs).
- `.iqtree` / `.log` – model fit and support values.


## Why snp-sites and IQ-TREE?

`snp-sites` takes the recombination-filtered alignment and keeps only
variable positions, giving a compact core-SNP alignment.

IQ-TREE:
- automatically tests models
- gives robust ML inference with bootstrap and SH-aLRT support, so that we can compare its topology to - `gubbins_raxml.final_tree.tre`.
- is widely used for bacterial core-genome trees

Together, they give a fast, well-supported ML tree on recombination-free
SNPs instead of raw whole-genome alignments.
