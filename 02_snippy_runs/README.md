# 02 – Per-genome variant calling (Snippy)

This step uses Snippy to call variants for each genome against `ref.fna`.

Main command:

```bash
while read id path; do
  snippy --ctgs "$path" \
         --ref ../01_inputs/ref.fna \
         --outdir snippy_runs/$id \
         --cpus 4 \
         --force
done < ../01_inputs/input.tab
```

Key outputs (per sample in snippy_runs/):

snps.aligned.fa: Per-sample alignment vs reference, used to build the core alignment.

snps.vcf: SNP calls.

snps.consensus.fa: Consensus sequence including variants.

## Why Snippy?

I chose Snippy because it takes assembled genomes and a single reference
and gives me:
- a clean per-sample alignment (`snps.aligned.fa`)
- SNP calls in VCF format

I did not want to write my own variant-calling pipeline or worry about
indexing, pileups, and filtering; Snippy wraps all of that in a single
command tuned for bacterial genomes.

