# 04 – Recombination analysis (Gubbins)

This step runs Gubbins on `core.full.aln` to detect and mask recombination.

Example command:

bash
run_gubbins.py --prefix gubbins_fast \
               --threads 24 \
               --tree-builder fasttree \
               ../03_core_alignment/core.full.aln
Gubbins iteratively builds trees, reconstructs ancestral states, and masks recombination.
The key recombination-filtered alignment from iteration 5 is:

core.full.iteration_5.internal.joint.aln

This alignment is used to derive the core SNP alignment for the final phylogeny.

