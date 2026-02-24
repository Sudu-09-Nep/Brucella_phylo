# 05 – Core SNP alignment and final tree

Here we reduce the recombination-filtered alignment to core SNPs and infer the final ML tree.

Commands:

bash
# Core SNP alignment
snp-sites -c ../04_gubbins_recombination/core.full.iteration_5.tre.snp_sites.aln > clean.core.aln

# Maximum-likelihood tree with IQ-TREE
iqtree2 -s clean.core.aln \
        -m GTR+G \
        -bb 1000 \
        -alrt 1000 \
        -nt AUTO

Important outputs:

clean.core.aln: Recombination-free core SNP alignment.

clean.core.aln.treefile: Final ML phylogeny of all genomes.


## Why snp-sites and IQ-TREE?

`snp-sites` takes the recombination-filtered alignment and keeps only
variable positions, giving a compact core-SNP alignment.

IQ-TREE:
- automatically tests models
- gives bootstrap and SH-aLRT support
- is widely used for bacterial core-genome trees

Together, they give a fast, well-supported ML tree on recombination-free
SNPs instead of raw whole-genome alignments.
