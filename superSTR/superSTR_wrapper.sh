#!/bin/bash


#----- Input dir -----
input_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/cogent_demux"


#----- Output dir ----

output_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/superSTR/superSTR_output_trimmedMT4"
mkdir -p $output_dir

#---- Run ------
echo "Running SuperSTR"

for r1 in $input_dir/*_R1.fastq.gz; 
do
    #echo "fastq: $fastq_path"
    # Extract information from file path
    # Keeps everything after MT 
    filename=$(basename "$r1" | grep -o 'MT.*')
    #echo "filename: $filename"
    sample=${filename%%_R*.fastq.gz}
    echo "================================"
    echo "Analyzing sample: $sample"

    outDir="$output_dir/$sample/"

    mkdir -p $outDir

    # Removes eveything before MT 
    cogent_stuff=$(basename "$r1" | grep -oP '.*(?=MT)')
    #echo "Cogent naming: $cogent_stuff"

    #Set up the read 1 and read 2 paths 
    read_1=${cogent_stuff}${sample}_R1.fastq.gz
    echo "read 1: $read_1"
    read_2=${cogent_stuff}${sample}_R2.fastq.gz
    echo "read 2: $read_2"

    inputR1="$input_dir/$read_1"
    inputR2="$input_dir/$read_2"


	sed \
	    -e "s%__OUTDIR__%${outDir}%g" \
        -e "s%__R1__%${inputR1}%g" \
        -e "s%__R2__%${inputR2}%g" \
	    -e "s%__JOB_NAME__%superSTR_${sample}%g" \
        run_superSTR_base.lsf | bsub
	echo "================================"

done 
echo "done"