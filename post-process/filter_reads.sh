#!/bin/bash

herv_name=$1

mkdir -p $herv_name

for bampath in tele_output/*/*updated.bam
do
prefix="${bampath%/*}"
prefix="${prefix##*/}"
samtools view -he '[XP] > 89' -d ZF:\"$herv_name\" $bampath > $herv_name/$prefix.sam
done
