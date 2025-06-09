#!/bin/bash
#BSUB -J bam_sort_wig
#BSUB -P acc_pMorpheus
#BSUB -q express
#BSUB -n 10
#BSUB -R "rusage[mem=5000]"           # Memory requirements
#BSUB -R "span[hosts=1]"              # All cores on the same node
#BSUB -W 02:00
#BSUB -o ./source/log_files/%J.stdout
#BSUB -eo ./source/log_files/%J.stderr
#BSUB -L /bin/bash

# Load necessary modules
module load python
module load java #11.0.1
module load samtools
module load igvtools

# --- Set up --- #
reference="/sc/arion/projects/pMorpheus/noah/1_SusannaRNAseq_2024_11_05/ref_seq/chr22.fa"
if [ $? -ne 0 ]; then
    echo "Reference fasta file not found: $reference"
    exit 1
fi

index_file=$(basename "$reference" | sed 's/\.[^.]*$//')
echo "Index file: $index_file"

typeOfAln="endToEnd"

bam_bw_output_path="/sc/arion/projects/pMorpheus/noah/1_SusannaRNAseq_2024_11_05/4_bam_sort_wig/$index_file/$typeOfAln"
tsv_output_path="./5_tsv/$index_file/$typeOfAln"

# Make directories
mkdir -p 4_bam_sort_wig/$index_file/$typeOfAln
mkdir -p 5_tsv/$index_file/$typeOfAln

BASE_DIR="./3_bowtie2/$index_file/$typeOfAln"
if [ ! -d "$BASE_DIR" ]; then
    echo "Base directory not found: $BASE_DIR"
    exit 1
fi

# Function to process a single SAM file
process_file() {
    fullpath="$1"
    filename=$(basename "$fullpath")
    base="${filename%%.*}"
    uniqueBase="$base.unique"
    echo "Processing: $base"


    # Making output files 
    bam_file="$bam_bw_output_path/$base.bam"
    header="$bam_bw_output_path/${base}.header"
    filtered_unique_bam="$bam_bw_output_path/$uniqueBase.bam"
    bam_sort_file="$bam_bw_output_path/$uniqueBase.sort.bam"
    wig_file="$bam_bw_output_path/$uniqueBase.wig"
    uniqueCount_tsv="$bam_bw_output_path/${uniqueBase}.tsv"
    tsvFile="$tsv_output_path/$uniqueBase.tsv"

    # Convert SAM to BAM
    samtools view -bS -o "$bam_file" "$fullpath"
    echo "Input is $fullpath"

    #Extracting only unique reads 

     samtools view -F 4 "$bam_file" | grep -v "XS:i:" | wc -l > "$uniqueCount_tsv"

    #extract unique reads 
    samtools view -H "$bam_file" > "$header"
    samtools view -F 4 "$bam_file" | grep -v "XS:i:" | cat "$header" - | \
    samtools view -b - > "$filtered_unique_bam"

    # Sort BAM (you can also enable samtools’ internal multithreading with -@ if beneficial)
    echo "Sorting $base"
    samtools sort -@ 2 "$bam_file" -o "$bam_sort_file"

    # Index the sorted BAM
    echo "Indexing $base"
    samtools index "$bam_sort_file"

    # Generate wiggle track
    echo "Running igvtools count for $base"
    igvtools count -z 5 -w 1 -e 250 --bases "$bam_sort_file" "$wig_file" "$reference"

    # Convert wig to TSV
    echo "Generating TSV for $base"
    python ./tools/wig_to_tsv_low_mem_REMOVEstopDel.py -i "$wig_file" -r "$reference" -o "$tsvFile"
}

# Limit concurrent jobs to 10 (or another number based on your resources)
max_jobs=10
job_count=0

for fullpath in "$BASE_DIR"/MT4*.sam; do
    process_file "$fullpath" &
    ((job_count++))
    # If we've hit the limit, wait for at least one job to finish
    if [ "$job_count" -ge "$max_jobs" ]; then
        wait -n
        ((job_count--))
    fi
done

# Wait for any remaining background jobs
wait

echo "All files processed."
