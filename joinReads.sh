#!/bin/bash
#BSUB -J joinReads 
#BSUB -P acc_pMorpheus
#BSUB -q express
#BSUB -n 4
#BSUB -R rusage[mem=8000]
#BSUB -W 02:00
#BSUB -o ./log_files/joinReads_%Jstdout
#BSUB -eo ./log_files/joinReads_%Jstderr
#BSUB -L /bin/bash

# Defining the paths (source and output)
RNAseqRun="AN00023282"
SOURCE_DIR="/sc/arion/projects/pMorpheus/2025-02-27_Takara_NovaSeq_TotalRNA/$RNAseqRun"
OUTPUT_DIR="/sc/arion/scratch/penan08/$RNAseqRun"


echo "Concatenating all read1 and read2 from $RNAseqRun"


# Make output directory (if not already made)
mkdir -p "$OUTPUT_DIR"

echo "Concatenated reads will be in: $OUTPUT_DIR"

# Define output files in the output directory
output_read1="${OUTPUT_DIR}/${RNAseqRun}_1.fastq.gz"
output_read2="${OUTPUT_DIR}/${RNAseqRun}_2.fastq.gz"

# Create empty fastq.gz files 
: > "$output_read1"
: > "$output_read2"

for dir in "$SOURCE_DIR"/*; do
    # Extract sample name from directory path
    sample="${dir##*/}"
    #echo "Dir: $dir"
    echo "Sample: $sample"

    # Create input file paths
    inputPathName="$dir/$sample"
    read1_input="${inputPathName}_1.fastq.gz"
    read2_input="${inputPathName}_2.fastq.gz"

    # Append fastq.gz contents to output files
    cat "$read1_input" >> "$output_read1"
    cat "$read2_input" >> "$output_read2"
done

echo "All done partner"
