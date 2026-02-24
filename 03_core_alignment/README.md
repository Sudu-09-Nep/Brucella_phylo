
# 03 – Whole-genome alignment (`core.full.aln`)

Here we combine all `snps.aligned.fa` files into a single whole-genome alignment with constant + variable sites.

Steps:

1. Use one sample (here `my_brucella`) to define contig order:

   ```bash
   grep '^>' ../02_snippy_runs/snippy_runs/my_brucella/snps.aligned.fa \
     | sed 's/^>//' | awk '{print $1}' > ref_contigs.order
