#!/bin/bash


# --- Setup ---
# Define variables
reference="/sc/arion/work/penan08/ref_seq/bowtie2_index/GRCH38.p13.onlychr4/GRCH38.p13.onlychr4"
output_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/bowtie2"
input_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/cogent_demux"
index_file="${reference##*/}"
suffix=".sam"

# Create output directories
mkdir -p "$output_dir"

outDir="${output_dir}/${index_file}/unTrimmed/"
mkdir -p "$outDir"
#mkdir -p ./3_bowtie2/output

# --- Main Processing Loop ---
for r1 in "$input_dir"/*_R1.fastq.gz;
do
   # Extract information from file path
    # Keeps everything after MT 
    filename=$(basename "$r1" | grep -o 'MT.*')
    echo "filename: $filename"
    sample=${filename%%_R*.fastq.gz}
    echo "Analyzing sample: $sample"


    # Removes eveything before MT 
    cogent_stuff=$(basename "$r1" | grep -oP '.*(?=MT)')
    #echo "Cogent naming: $cogent_stuff"

    #Set up the read 1 and read 2 paths 
    read_1=${cogent_stuff}${sample}_R1.fastq.gz
    echo "read 1: $read_1"
    read_2=${cogent_stuff}${sample}_R2.fastq.gz
    echo "read 2: $read_2"

    #Finalize input files
    in1="$input_dir/$read_1"
    in2="$input_dir/$read_2"
    outFile="$outDir/$sample$suffix"

    echo "Processing sample: $sample"

    #Run bowtie2 
    echo " Submitting bowtie2 job"
    sed \
        -e "s%__REF__%${reference}%g" \
        -e "s%__INPUT1__%${in1}%g" \
        -e "s%__INPUT2__%${in2}%g" \
        -e "s%__OUTPUT__%${outFile}%g" \
        -e "s%__JOB_NAME__%bowtie2_${sample}%g" \
        run_bowtie2_pairedEnd.lsf | bsub

done
