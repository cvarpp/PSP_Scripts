#!/bin/bash
#BSUB -J superSTR_plot
#BSUB -P acc_pMorpheus
#BSUB -q express
#BSUB -n 2
#BSUB -R "rusage[mem=5G]"           # Memory requirements
#BSUB -R "span[hosts=1]"              # All cores on the same node
#BSUB -W 10:00
#BSUB -o /sc/arion/work/penan08/log_files/superSTR_plot_%J.stdout
#BSUB -eo /sc/arion/work/penan08/log_files/superSTR_plot_%J.stderr
#BSUB -L /bin/bash

#--- Load modules ----
echo "######## Activating conda enviroiment superSTR ########"
module load anaconda3
eval "$(conda shell.bash hook)"
source activate superSTR_vis


#----- Input dir -----
input_dir="/sc/arion/projects/pMorpheus/noah/3_APOBEC3_analysis/superSTR/HD_STR_analysis/"


#----- Output dir ----
output_dir="$input_dir/processed_output"
mkdir -p $output_dir
output_dir_readid="$output_dir/readIDinfo"
mkdir -p $output_dir_readid

#--- manifest ----
manifest_dir="/sc/arion/work/penan08/5_huntingtonProject"

#--- SuperSTR dir ----
superSTRdir="/sc/arion/work/penan08/tools/my_apps/superSTR"

#--- plots dir ---
output_plots_dir="${output_dir}plots/"
mkdir -p $output_plots_dir


#---- Run ------
known_pathogenic_motifs=(
    3mers/AGC.csv
    5mers/AAAGT.csv
    5mers/AAATG.csv
    12mers/CCCCGCCCCGCG.csv
    6mers/CCCCGG.csv
    3mers/AAG.csv
    5mers/AATAG.csv
    3mers/ACG.csv
    3mers/CCG.csv
    6mers/AGGCCC.csv 
    4mers/AGGC.csv
    5mers/AATGG.csv
)

for line in "${known_pathogenic_motifs[@]}"; do

    moti_name="${line%.csv}"
    echo "Looking at motif: $motif_name"

    clean_motif_name="${motif_name//\//_}"


    #Running Visualizataion
    echo "--- Running visualize script"
    python $superSTRdir/Python/visualise_withDebug.py \
    -i ${output_dir}motifs/$line \
    -o "${output_plots_dir}$clean_motif_name.pdf" \
    -m "$manifest_dir/MT4-A3A-NT_manifest.tsv" \
    --aff_lab A3A --ctrl_lab NT

done