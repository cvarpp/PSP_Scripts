#!/bin/bash

BAM_DIR=$1

mkdir -p tele_out

for bam_path in $BAM_DIR/*.bam
do
    bam="${bam_path##*/}"
    exp_tag="${bam%.bam}"
    echo "Telescoping ${exp_tag}"
    ./telescope_wrap.sh "${exp_tag}" hg38.HERV.gtf
done
