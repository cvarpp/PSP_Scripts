#!/bin/bash

#BSUB -J __JOB_NAME__                # Job name
#BSUB -P acc_pMorpheus                # Project name
#BSUB -q express                      # Queue name
#BSUB -n 10                           # Number of cores
#BSUB -R "rusage[mem=3000]"           # Memory requirements
#BSUB -R "span[hosts=1]"              # All cores on the same node
#BSUB -W 08:00                        # Walltime (HH:MM)
#BSUB -o /sc/arion/work/penan08/log_files/__JOB_NAME__%J.stdout
#BSUB -eo /sc/arion/work/penan08/log_files/__JOB_NAME__%J.stderr
#BSUB -L /bin/bash                    # Shell to use


#-- configure enviroment 
module load bowtie2

# Run Bowtie2
bowtie2 -x "__REF__" -1 "__INPUT1__" -2 "__INPUT2__" -S "__OUTPUT__" -q -p 10 --no-unal