#!/bin/bash
#BSUB -J fastqMerge
#BSUB -P acc_pMorpheus
#BSUB -q express
#BSUB -n 3
#BSUB -R "rusage[mem=3G]"           # Memory requirements
#BSUB -R "span[hosts=1]"              # All cores on the same node
#BSUB -W 10:00
#BSUB -o /sc/arion/work/penan08/log_files/fastq_Merge_%J.stdout
#BSUB -eo /sc/arion/work/penan08/log_files/fastq_Merge_%J.stderr
#BSUB -L /bin/bash


# --- Input dir ----
input_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/cogent_demux"


#----- Output dir ----

output_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/fastq_allSamples_together"
mkdir -p $output_dir


#---- Run ------
echo "Merge fastq.gz files"

echo "Merging all: A3A_R1 files together"
zcat $input_dir/*A3A*R1.fastq.gz | gzip -c > $output_dir/MT4_A3A_R1.fastq.gz

echo "Merging all: A3A_R2 files together"
zcat $input_dir/*A3A*R2.fastq.gz | gzip -c > $output_dir/MT4_A3A_R2.fastq.gz

echo "Merging all: NT_R1 files together"
zcat $input_dir/*NT*R1.fastq.gz | gzip -c > $output_dir/MT4_NT_R1.fastq.gz

echo "Merging all: NT_R2 files together"
zcat $input_dir/*NT*R2.fastq.gz | gzip -c > $output_dir/MT4_NT_R2.fastq.gz


echo "Done"