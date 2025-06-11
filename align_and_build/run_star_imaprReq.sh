#!/bin/bash
#BSUB -J starAlign
#BSUB -P acc_pMorpheus
#BSUB -q express
#BSUB -n 3
#BSUB -R "rusage[mem=5000]"           # Memory requirements
#BSUB -R "span[hosts=1]"              # All cores on the same node
#BSUB -W 10:00
#BSUB -o /sc/arion/work/penan08/log_files/starAlignment_%J.stdout
#BSUB -eo /sc/arion/work/penan08/log_files/starAlignment_%J.stderr
#BSUB -L /bin/bash

#--- Load modules ----
echo "Activating STAR module "
module load star


#----- Input dir -----
input_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/cogent_demux"


#----- Output dir ----

output_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/STAR_output/"
mkdir -p $output_dir

#--- genome dir -----
genome_dir="/sc/arion/scratch/penan08/genomes/STAR"

#---- Run ------
echo "Running STAR aligner"

for r1 in $input_dir/*_R1.fastq.gz; 
do
    #echo "fastq: $fastq_path"
    # Extract information from file path
    # Keeps everything after MT 
    filename=$(basename "$r1" | grep -o 'MT.*')
    #echo "filename: $filename"
    sample=${filename%%_R*.fastq.gz}
    echo "Analyzing sample: $sample"

    #mkdir -p $output_dir/$sample

    # Removes eveything before MT 
    cogent_stuff=$(basename "$r1" | grep -oP '.*(?=MT)')
    #echo "Cogent naming: $cogent_stuff"

    #Set up the read 1 and read 2 paths 
    read_1=${cogent_stuff}${sample}_R1.fastq.gz
    echo "read 1: $read_1"
    read_2=${cogent_stuff}${sample}_R2.fastq.gz
    echo "read 2: $read_2"

    # STAR \
    # --genomeDir "$genome_dir" \
    # --readFilesIn "$read_1" "$read_2"
    # --alignIntronMax 1000000 \
    # --alignIntronMin 20 \
    # --alignMatesGapMax 1000000 \
    # --alignSJDBoverhangMin 1 \
    # --alignSJoverhangMin 8 \
    # --alignSoftClipAtReferenceEnds Yes \
    # --chimJunctionOverhangMin 15 \
    # --chimMainSegmentMultNmax 1 \
    # --chimOutJunctionFormat 1 \
    # --chimSegmentMin 15 \
    # --limitSjdbInsertNsj 1200000 \
    # --outFilterInMotifs None \
    # --outFilterMatchNminOverLread 0.33 \
    # --outFilterMismatchNmax 999 \
    # --outFilterMismatchNoverLmax 0.1 \
    # --outFilterMultimapNmax 20 \
    # --outFilterScoreMinOverLread 0.33 \
    # --twopassMode Basic \
    # --outSAMmapqUnique 60


done 
echo "done"