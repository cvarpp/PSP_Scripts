#!/bin/bash

# LSF job directives
#BSUB -J imapr                # Job name
#BSUB -P acc_pMorpheus                # Project name
#BSUB -q express                      # Queue name
#BSUB -n 15                           # Number of cores
#BSUB -R "rusage[mem=200G]"           # Memory requirements
#BSUB -R "span[hosts=1]"              # All cores on the same node
#BSUB -W 11:00                        # Walltime (HH:MM)
#BSUB -o /sc/arion/work/penan08/log_files/imapr_%J.stdout # Standard output file
#BSUB -eo /sc/arion/work/penan08/log_files/imapr_%J.stderr # Standard error file
#BSUB -L /bin/bash                    # Shell to use


# Load modules and activate conda envirioment
module load anaconda3/latest
source activate apobec3_project
module load samtools
module load bcftools
module load java
module load hisat2


# Path to pipeline txt
inputDir="/sc/arion/work/penan08/4_somatic_mutationAnalysis/MT4_sample_input/"

#Path to IMAPR.sh script
impar_path="/sc/arion/work/penan08/tools/my_apps/imapr_v2.0"


for pipeline_txt in "$input_dir"/*.txt;
do


    # run script

    bash $impar_path/IMAPR.sh "$pipeline_txt"

    echo "Done"

done