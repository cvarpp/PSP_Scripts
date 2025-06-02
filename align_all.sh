#!/bin/bash

FASTQ_DIR=$1

mkdir -p mapped_3.23

for fastq1_path in $FASTQ_DIR/*R1.fastq.gz
do
    fastq1="${fastq1_path##*/}"
    # exp_tag="${fastq1#cogent_demux_longRun_????????????????_}"
    exp_tag="${fastq1#cogent_demux_longRun_}"
    exp_tag="${exp_tag%_R1.fastq.gz}"
    echo "Aligning ${exp_tag}"
    ./hisat2_wrap.sh "${exp_tag}"
done
