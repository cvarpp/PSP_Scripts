#!/bin/bash

for gtf in hg38.*.gtf
do
    bam_prefix="AGTATAGTGCTGGTCA_NCCIT_12_23"
    ./telescope_wrap.sh $bam_prefix $gtf
done
