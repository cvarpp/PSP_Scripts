#!/bin/bash

#—— Configuration ——#
inputDir="/sc/arion/projects/HERVP/2025-05-27_Takara_NovaSeq_TotalRNA/cogent_demux_output_cleanUp"
outputDir="/sc/arion/projects/HERVP/2025-05-27_Takara_NovaSeq_TotalRNA/cogent_analyze_output/"
#genome="{hg38}"

# sanity‐check cogent demx output exist, then create outputDir
if [[ -d "$inputDir" && $(ls -A "$inputDir") ]]; then
    echo "Using Cogent Demux output: $inputDir"
else
	echo "ERROR: No cogent demux output directory not found" >&2
	exit 1
fi
mkdir -p "$outputDir"

#build an array of input dir
samples_array=($(ls -d $inputDir/*))

#echo ${samples_array[@]}

# loop over each sample directory (contains raw fastq.gz)
#for sample in "$inputDir"/*; do
for sample in "${samples_array[@]}"; do
	echo "Input dir : $sample"
	sample_name=$(basename "$sample")

    # skip either of the two cogent‐output dirs
	if [[ "$sample_name" == "tmpSampleSheets" ]]; then
	  echo "  Ignoring temp dir: $sample_name"
	  continue
	fi
	echo "================================"
	echo " Preparing sample: $sample_name "
	echo "================================"



	thisOut="$outputDir/$sample_name"

	echo " Running cogent analyze "
	sed \
	    -e "s%__INPUTDIR__%${sample}%g" \
	    -e "s%__OUTDIR__%${thisOut}%g" \
	    -e "s%__JOB_NAME__%cogentAnlayze_${sample_name}%g" \
	    run_cogent_analyze.lsf | bsub
	echo "================================"


done