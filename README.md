# Brucella recombination-aware core-genome phylogenomics

This repository is a **step-by-step story** of how I went from assembled
genomes to a recombination-filtered core SNP phylogeny using Snippy,
Gubbins, snp-sites, and IQ-TREE.

When I first ran this pipeline, I could execute the commands but did not
really understand what each tool was doing or why I chose it.  
Here, each folder is a chapter that explains:

- what was done at that step  
- which files matter  
- why that tool/approach was used (not just how to run it)

The goal is that you can understand the reasoning, not just re-run the
commands.

---

## Project structure (chapters of the story)

- `01_inputs/` – starting genomes and metadata  
- `02_snippy_runs/` – per-genome variant calling vs a single reference (Snippy)  
- `03_core_alignment/` – whole-genome alignment (`core.full.aln`) construction  
- `04_gubbins_recombination/` – recombination detection and masking (Gubbins)  
- `05_core_SNP_tree/` – recombination-free core SNP alignment and ML tree (snp-sites + IQ-TREE)  
- `NCBI_README.md` – original README from the NCBI Datasets download

Each of these folders has its own `README.md` describing the logic of
that step, key commands, and the important outputs.

---

## 01 – Inputs (what data goes in)

Folder: `01_inputs/`

This chapter collects all the starting material:

- `ref.fna` – reference genome (*Brucella/Ochrobactrum* sp.)  
- `my_brucella.fna` – polished assembly of the focal isolate  
- `input.tab` – two-column table: sample ID and absolute path to each assembly  
- `gcf_genomes.list` – list of NCBI RefSeq/GenBank accessions

These files define which genomes are included and what “reference view”
Snippy will use for all samples.

---

## 02 – Per-genome variant calling (Snippy)

Folder: `02_snippy_runs/`

Here I use **Snippy** to compare each genome to the same reference and
produce per-sample alignments and VCFs.

Conceptually, Snippy:

- maps each assembly to `ref.fna`  
- calls SNPs and small indels  
- outputs `snps.aligned.fa`, which is the reference sequence with
  sample-specific bases substituted at variant sites

I chose Snippy because it wraps mapping, variant calling, and basic
filtering into a single command tuned for bacterial genomes, so I don’t
have to glue together multiple tools myself.

---

## 03 – Whole-genome alignment (`core.full.aln`)

Folder: `03_core_alignment/`

From all the `snps.aligned.fa` files, I build a whole-genome alignment
where:

- each row is a genome  
- all sequences have the same length (the reference length)  
- both constant and variable sites are present

Instead of relying on a “magic” script, I explicitly:

1. Use one representative Snippy output to define contig order.  
2. Concatenate contigs in that fixed order for every sample.

This made me understand that Gubbins needs a full alignment with constant
sites, and that contig order matters for keeping the genome structure
comparable across isolates.

---

## 04 – Recombination analysis (Gubbins)

Folder: `04_gubbins_recombination/`

Here I run **Gubbins** on `core.full.aln` to detect and mask
recombination.

Algorithmically, Gubbins:

- iteratively builds phylogenetic trees  
- uses ancestral reconstruction to identify clusters of SNPs that look
  like recombination rather than vertical mutation  
- masks those regions and rebuilds the tree until convergence

I chose Gubbins because I did not want recombination to mislead the
phylogeny; this is especially important for organisms where horizontal
exchange is non-negligible.

The key output is a recombination-filtered alignment (e.g.
`core.full.iteration_5.internal.joint.aln`) that represents the “clean”
core genome signal.

---

## 05 – Core SNP alignment and final tree

Folder: `05_core_SNP_tree/`

Finally, I reduce the recombination-filtered alignment to core SNPs and
build a maximum-likelihood tree.

Two key tools:

- **snp-sites** – extracts only variable positions from the alignment,
  producing a compact core-SNP matrix suitable for ML methods.  
- **IQ-TREE** – infers a maximum-likelihood phylogeny, tests models, and
  provides branch support (bootstraps, SH-aLRT).

The important files in this chapter are:

- `clean.core.aln` – recombination-free core SNP alignment  
- `clean.core.aln.treefile` – final ML tree (Newick)

This chapter tells the last part of the story: how the clonal
relationships among genomes look after accounting for recombination.

---

## What this repo tries to teach

This repository is not only a record of commands; it is a learning
exercise:

- to see how per-genome SNP calling becomes a shared core alignment  
- to understand why recombination must be filtered  
- to link each command to its conceptual role in the analysis

If you follow the chapters in order and read the `README.md` files in
each folder, you should be able to understand **why** each tool appears,
what data structure it expects, and what it produces.
