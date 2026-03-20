#!/bin/bash

cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo

# 1. Define reference contig order
grep '^>' ref.fna | sed 's/^>//' | awk '{print $1}' > ref_contigs.order

# 2. Run Snippy per sample (using input.tab)
while IFS=$'\t' read -r sample r1 r2; do
    snippy --outdir snippy_runs/"$sample" --ref ref.fna --r1 "$r1" --r2 "$r2"
done < input.tab

# 3. Build full reference-based alignment
mkdir -p alignments
cd alignments
ls ../snippy_runs > samples.list

> core.full.aln
while read sample; do
    snpfile="../snippy_runs/$sample/snps.aligned.fa"
    echo ">$sample" >> core.full.aln
    while read contig; do
        samtools faidx "$snpfile" "$contig" \
        | awk 'NR>1 {printf "%s", $0}'
    done < ../ref_contigs.order >> core.full.aln
    echo >> core.full.aln
done < samples.list

# 4. Remove genomes with no SNP signal (RAxML error list)
cat > bad_samples.txt <<EOF
GCA_001575075.1
GCA_001586735.1
GCA_002296345.1
GCA_002387885.1
GCA_002391935.1
GCA_002431065.1
GCA_002453395.1
GCA_002454835.1
GCA_002462635.1
GCA_002477165.1
GCA_003528245.1
GCA_003937445.1
GCA_028620865.1
EOF

seqkit grep -v -f bad_samples.txt core.full.aln > core.full.reduced.aln

# 5. Run Gubbins with RAxML
micromamba activate gubbins_env

nohup run_gubbins.py \
  --prefix gubbins_raxml \
  --threads 24 \
  --tree-builder raxml \
  core.full.reduced.aln \
  > gubbins_raxml.log 2>&1 &

# 6. (After Gubbins finishes) SNP alignment + IQ-TREE
cd ~/Documents/Pradu/Sudu/Trycycler_Brucella/brucella_phylo/alignments

snp-sites -c gubbins_raxml.filtered_polymorphic_sites.fasta > core_snps_gubbins.aln

iqtree2 -s core_snps_gubbins.aln -m GTR+G -bb 1000 -alrt 1000 -nt AUTO
