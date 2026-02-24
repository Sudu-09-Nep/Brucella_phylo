
# 03 – Whole-genome alignment (`core.full.aln`)

Here we combine all `snps.aligned.fa` files into a single whole-genome alignment with constant + variable sites.

Steps:

1. Use one sample (here `my_brucella`) to define contig order:

   bash
   grep '^>' ../02_snippy_runs/snippy_runs/my_brucella/snps.aligned.fa \
     | sed 's/^>//' | awk '{print $1}' > ref_contigs.order


2. Build core.full.aln by concatenating contigs in that order for every sample.

The file core.full.aln is the starting point for recombination analysis with Gubbins.

