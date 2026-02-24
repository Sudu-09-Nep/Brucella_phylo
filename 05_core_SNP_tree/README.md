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

