#!/bin/bash

FASTQ_DIR=$1

mkdir -p hisat2_output

for fastq1_path in $FASTQ_DIR/*R1.fastq.gz
do
    fastq1="${fastq1_path##*/}"
    fastq2="${fastq1%R*}R2.fastq.gz"
    exp_tag="${fastq1#cogent_demux_longRun_????????????????_}"
    exp_tag="${exp_tag%_R1.fastq.gz}"
    echo "Aligning ${exp_tag}"
    snakemake "tele_out/${exp_tag}.updated.bam"
done
