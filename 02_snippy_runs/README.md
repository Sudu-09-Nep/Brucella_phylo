# 02 – Per-genome variant calling (Snippy)

This step uses Snippy to call variants for each genome against `ref.fna`.

Main command:

bash
while read id path; do
  snippy --ctgs "$path" \
         --ref ../01_inputs/ref.fna \
         --outdir snippy_runs/$id \
         --cpus 4 \
         --force
done < ../01_inputs/input.tab

Key outputs (per sample in snippy_runs/):

snps.aligned.fa: Per-sample alignment vs reference, used to build the core alignment.

snps.vcf: SNP calls.

snps.consensus.fa: Consensus sequence including variants.
