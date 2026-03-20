
# 03 – Whole-genome alignment (`core.full.aln`)

Here we combine all `snps.aligned.fa` files into a single whole-genome alignment with constant + variable sites.

Steps:

1. Use one sample (here `my_brucella`) to define contig order:
In your working directory. In my case it is:- 

```bash
cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo

grep '^>' ref.fna \
  | sed 's/^>//' \
  | awk '{print $1}' > ref_contigs.order

head ref_contigs.order
```
This ensures that we always concatenate contigs in the same order(e.g. chromosome 1, chromosome 2...... plasmids for every genome)
This also makes all sequences in final alignment aligned in coordinate space(position X always mean the same locus in the reference).

2. Inside alignments
```bash
cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo

mkdir -p alignments
cd alignments

ls ../snippy_runs > samples.list
wc -l samples.list   #Should show the number of samples you are working with.     
```

Here sample.list is the set of genomes we will include in the phylogeny( SmpleIDs = folder names in snippy_runs)

3. Build core.full.aln by concatenating contigs in that order for every sample.

```bash
cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo/alignments

> core.full.aln
while read sample; do
    echo "Processing $sample"
    snpfile="../snippy_runs/$sample/snps.aligned.fa"

    # FASTA header for this sample
    echo ">$sample" >> core.full.aln

    # Concatenate all contigs in the canonical reference order
    while read contig; do
        samtools faidx "$snpfile" "$contig" \
        | awk 'NR>1 {printf "%s", $0}'
    done < ../ref_contigs.order >> core.full.aln

    echo >> core.full.aln  # newline after sequence
done < samples.list

```

The file core.full.aln is the starting point for recombination analysis with Gubbins.
**What happens mathematically here is:**
For each sample:

- For each sample:
    - For each reference contig in `ref_contigs.order`:
        - `samtools faidx` pulls the aligned sequence for that contig from `snps.aligned.fa`.
        - `awk 'NR>1 {printf "%s", $0}'` removes header and joins lines into one continuous string.
    - All contig strings are concatenated into one long sequence of length ≈ genome size of reference.
- Each line in `core.full.aln` corresponds to **one genome** as a complete, reference-aligned sequence.

Check:

```bash
`grep -c '^>' core.full.aln    # 186 (one per line in samples.list)
grep -v '^>' core.full.aln | awk '{print length}' | sort -nu
# You should see a single length value (all sequences same length)`
```

**Concept:**

`core.full.aln` is a  **whole-genome alignment**: 1 sequence per genome, all on PBO_ref coordinates, including constant and variable sites.



***NOTE ON METHODOLOGY***
Instead of employing traditional Multiple Sequence Alignment (MSA) algorithms (e.g., MAFFT, MUSCLE), which are computationally intensive for large bacterial genomes and can struggle with rearrangements, a reference-based variant projection approach was used.

Variant Mapping: Each assembly was mapped against the reference genome (Brucella sp.) using Snippy v4.6.0. This identified SNPs and indels while maintaining the reference coordinate system for every isolate.

Pseudogenome Generation: For each sample, a "aligned" version of the reference was generated where variant sites were replaced by the sample-specific base, and non-variant/uncovered sites were maintained or masked.

Concatenation: These fixed-length pseudogenomes were concatenated to form a whole-genome core alignment (core.full.aln).

Rationale: This method ensures that every row in the final matrix is of identical length and that genomic positions remain homologous across the entire dataset. This is a prerequisite for recombination detection in Gubbins, which requires a full alignment (including constant sites) to accurately model spatial SNP density.
