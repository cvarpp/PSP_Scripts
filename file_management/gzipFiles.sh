#!/bin/bash 

# LSF job directives
#BSUB -J gzipCOmpress               # Job name
#BSUB -P acc_pMorpheus               # Project name
#BSUB -q express                     # Queue name
#BSUB -n 3                          # Number of cores
#BSUB -R "rusage[mem=2G]"          # Memory requirements
#BSUB -R "span[hosts=1]"             # All cores on the same node
#BSUB -W 4:00
#BSUB -o /sc/arion/work/penan08/log_files/gzipFiles_%J.stdout
#BSUB -eo /sc/arion/work/penan08/log_files/gzipFiles_%J.stderr
#BSUB -L /bin/bash                   # Shell to use

set -euo pipefail

#Check if directory arugment is given
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <directory>" >&2
  exit 1
fi

dir=$1

#Check if direcotyr exist
if [[ ! -d "$dir" ]]; then
  echo "Error: Directory '$dir' not found." >&2
  exit 1
fi

for fastq in $dir/*; do

    echo "Gzipping $fastq"

    #gzip $fastq 

done 

echo "Done gzipping files in $dir"