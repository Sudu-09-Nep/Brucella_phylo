# Brucella / Ochrobactrum recombination-aware core-genome phylogenomics

This repository contains a fully reproducible pipeline to build a recombination-filtered core-genome SNP phylogeny from complete and draft genomes using **Snippy**, **Gubbins**, **snp-sites**, and **IQ-TREE**.  
It starts from assembled genomes (including a polished *Brucella* genome of interest and RefSeq assemblies from NCBI Datasets) and ends with a maximum-likelihood tree based on recombination-free core SNPs.

## Overview

Main steps:

1. Prepare inputs (reference genome, custom assembly, and 80+ RefSeq genomes from NCBI Datasets).
2. Run **Snippy** per genome against a single reference to generate per-sample SNP alignments. [Snippy][snippy]
3. Construct a whole-genome alignment (`core.full.aln`) by concatenating contigs in a consistent order across all samples.
4. Run **Gubbins** on `core.full.aln` to detect and mask recombination. [Gubbins][gubbins]
5. Use **snp-sites** to extract recombination-free core SNPs.
6. Build a maximum-likelihood phylogeny with **IQ-TREE** on the recombination-filtered core SNP alignment.

The final outputs are a recombination-aware core-genome tree and the corresponding alignment.

---

## 1. Input data and directory structure

Working directory (this repo):

```bash
brucella_phylo/
├── alignments/
├── ncbi_dataset/
├── snippy_runs/
├── my_brucella.fna
├── ref.fna
├── input.tab
└── README.md

Key files and folders:

ref.fna – reference genome (e.g. Brucella anthropi).

my_brucella.fna – polished assembly of the focal strain.

ncbi_dataset/ – NCBI Datasets genome package (RefSeq assemblies and metadata). NCBI Datasets

input.tab – two-column tab-delimited file: sample ID and absolute path to each .fna file.

snippy_runs/ – per-sample Snippy outputs (created by this pipeline).

alignments/ – constructed whole-genome and core-SNP alignments, Gubbins and IQ-TREE outputs.

Example input.tab format:

GCF_000017405.1_ASM1740v1_genomic    /full/path/ncbi_dataset/data/GCF_000017405.1/GCF_000017405.1_ASM1740v1_genomic.fna
...
my_brucella                           /full/path/brucella_phylo/my_brucella.fna


2. Per-genome variant calling with Snippy
Snippy is used to call SNPs and small indels for each genome against the same reference (ref.fna), producing per-sample snps.aligned.fa and VCF files. [web:40][web:20]

Activate the environment and run Snippy for all genomes in input.tab:
micromamba activate snippy_clean   # or: conda activate snippy_clean

cd /path/to/brucella_phylo

while read id path; do
    echo "Running snippy on $id"
    snippy --ctgs "$path" \
           --ref ref.fna \
           --outdir snippy_runs/$id \
           --cpus 4 \
           --force
done < input.tab

Check you have outputs for all samples:

find snippy_runs -type f -name snps.aligned.fa | wc -l
# expect: number of samples in input.tab

3. Define contig order for whole-genome alignment
To build a whole-genome alignment with constant sites, we concatenate contigs in a fixed order using one representative Snippy alignment (here, my_brucella). [web:23]

bash
cd /path/to/brucella_phylo

grep '^>' snippy_runs/my_brucella/snps.aligned.fa \
  | sed 's/^>//' \
  | awk '{print $1}' \
  > ref_contigs.order

cat ref_contigs.order
# Example:
# NZ_CP064064.1
# (additional contigs if present)

4. Build whole-genome alignment core.full.aln
We now build a full-length alignment (one sequence per genome, equal length) by concatenating contigs for all snps.aligned.fa files in the same order. This alignment includes both constant and variable sites and is suitable for Gubbins. [web:23][web:45]

bash
cd /path/to/brucella_phylo

mkdir -p alignments
cd alignments

# List all per-sample snps.aligned.fa paths
find ../snippy_runs -type f -name snps.aligned.fa | sort > snps_paths.list
wc -l snps_paths.list    # should equal number of samples

Construct the whole-genome alignment:

bash
> core.full.aln
while read path; do
    sample=$(basename "$(dirname "$path")")
    echo "Processing $sample"

    echo ">$sample" >> core.full.aln

    # Concatenate contigs in fixed order
    while read contig; do
        seqkit grep -r -p "$contig" "$path" \
        | tail -n +2 \
        | tr -d '\n'
    done < ../ref_contigs.order >> core.full.aln

    echo >> core.full.aln
done < snps_paths.list

Verify that all sequences have the same length:

bash
grep -v '^>' core.full.aln | awk '{print length}' | sort -nu
# Single non-zero value = OK

5. Recombination analysis with Gubbins
Gubbins iteratively identifies recombination and masks those regions to produce a recombination-filtered alignment. [web:45]

Run Gubbins on the whole-genome alignment:

bash
cd /path/to/brucella_phylo/alignments

run_gubbins.py --prefix gubbins_fast \
               --threads 24 \
               --tree-builder fasttree \
               core.full.aln
Key outputs include:

gubbins_fast.final_tree.tre – phylogeny inferred from recombination-filtered sites.

gubbins_fast.filtered_polymorphic_sites.fasta – recombination-masked alignment of polymorphic sites.

If a run stops after iteration 5 but fails to write the final summary files, the recombination-corrected alignment can be recovered from:

bash
alignments/tmph*/core.full.iteration_5.internal.joint.aln
This file is equivalent to what Gubbins would use to generate gubbins_fast.filtered_polymorphic_sites.fasta


. Core SNP alignment and IQ-TREE phylogeny
To obtain a compact core-SNP alignment for phylogenetic inference, we use snp-sites on the recombination-filtered alignment and then run IQ-TREE. [web:23][web:20][web:43]

Example using a Gubbins iteration 5 alignment:

bash
# Extract core SNPs from recombination-filtered alignment
snp-sites -c core.full.iteration_5.tre.snp_sites.aln > clean.core.aln

# Inspect length
grep -v '^>' clean.core.aln | awk '{print length}' | sort -nu
Build a maximum-likelihood tree with IQ-TREE:

bash
iqtree2 -s clean.core.aln \
        -m GTR+G \
        -bb 1000 \
        -alrt 1000 \
        -nt AUTO
Important outputs:

clean.core.aln.treefile – final ML tree (Newick).

clean.core.aln.iqtree – model fit, support statistics, and run diagnostics.

7. Software versions
(Example; adjust to match your environment.)

Snippy: see Snippy GitHub. [web:40]

Gubbins: see Gubbins documentation. [web:45]

snp-sites: latest release from the samtools/htslib ecosystem.

IQ-TREE: IQ-TREE 2 (iqtree2).

Recording exact versions here (or in an environment.yml) is recommended for full reproducibility.

8. NCBI Datasets package
The ncbi_dataset/ directory was generated using the NCBI Datasets command-line tool and contains:

RefSeq genome FASTA files under ncbi_dataset/data/.

Metadata files (e.g. assembly_data_report.jsonl, dataset_catalog.json). [web:32][web:33][web:44]

For details on generating similar packages, see the NCBI Datasets documentation. [web:32][web:38]

References
Snippy: rapid haploid variant calling and core-genome alignment. [web:40][web:20]

Gubbins: iterative recombination detection and recombination-free phylogenies. [web:45]

NCBI Datasets: download genome data packages and metadata from RefSeq/GenBank. [web:32][web:33][web:44]


