# 02 – Per-genome variant calling (Snippy)

This step uses Snippy to call variants for each genome against `ref.fna`.

Main command:

```bash
while IFS=$'\t' read -r sample r1 r2; do
    snippy \
      --outdir snippy_runs/"$sample" \
      --ref ref.fna \
      --r1 "$r1" --r2 "$r2"
done < input.tab
```
Key outputs (per sample in snippy_runs/):
Result:
```bash
ls snippy_runs/
GCA_000017405.1  GCA_000251205.1  ...  GCF_900454235.1  MyBrucella  PBO_ref

ls snippy_runs/MyBrucella
snps.aligned.fa  snps.vcf  snps.raw.vcf  ...
```

Here, Each `snps.aligned.fa` is a **per-sample alignment to the reference**, with:

- Headers = reference contig names (chromosomes/plasmids).
- Sequences = that sample’s consensus sequence at each reference position, including SNPs and gaps.


snps.vcf: SNP calls.

## Why Snippy?

I chose Snippy because it takes assembled genomes and a single reference
and gives me:
- a clean per-sample alignment (`snps.aligned.fa`)
- SNP calls in VCF format

I did not want to write my own variant-calling pipeline or worry about
indexing, pileups, and filtering; Snippy wraps all of that in a single
command tuned for bacterial genomes.

