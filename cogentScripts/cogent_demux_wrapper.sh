#!/bin/bash

#—— Configuration ——#
inputDir="/sc/arion/projects/HERVP/2025-05-27_Takara_NovaSeq_TotalRNA"
sampleSheet="/sc/arion/projects/pMorpheus/noah/Cogent_AP/SampleSheet/2025_05_27_Takara_SMART_RNAseqRun/HERVP_sampleSheet.csv"
outputDir="/sc/arion/projects/HERVP/2025-05-27_Takara_NovaSeq_TotalRNA/cogent_demux_output_cleanUp"

# sanity‐check sampleSheet, then create outputDir
if [[ ! -f "$sampleSheet" ]]; then
	echo "ERROR: sample sheet not found" >&2
	exit 1
fi
mkdir -p "$outputDir"

#build an array of input dir
samples_array=($(ls -d $inputDir/*))

#echo ${samples_array[@]}

# loop over each sample directory (contains raw fastq.gz)
#for sample in "$inputDir"/*; do
for sample in "${samples_array[@]}"; do
	#echo "Sample : $sample"
	sample_name=$(basename "$sample")
	echo "================================"
	echo " Preparing sample: $sample_name "
	echo "================================"

	# skip either of the two cogent‐output dirs
	if [[ "$sample_name" == "cogent_demux_output" ]] || [[ "$sample_name" == "cogent_demux_output_cleanUp" ]]; then
	  echo "  Ignoring output dir: $sample_name"
	  continue
	fi

	read1="$sample/${sample_name}_1.fastq.gz"
	read2="$sample/${sample_name}_2.fastq.gz"
	# read1="${sample_name}_1.fastq.gz"
	# read2="${sample_name}_1.fastq.gz"
	thisOut="$outputDir/$sample_name"

	# Create a filtered sample sheet for just the current sample being analyzed 
	filtered_sheet="$outputDir/tmpSampleSheets/${sample_name}_samplesheet.csv"
	mkdir -p "$(dirname "$filtered_sheet")"

	# Get the header from the sample sheet 
	head -n1 "$sampleSheet" > "$filtered_sheet"

	#Start getting the the output of the sample sheet starting on the second line
	tail -n +2 "$sampleSheet" | \
		#Use awk on a comma-seperated file (-F), -v sets a variable s = sample_name. If a value on the second column equals s it is kept
  		awk -F, -v s="$sample_name" '$2==s { print }' \
  		>> "$filtered_sheet"

	# count lines (header + any matching rows)
	line_count=$(wc -l < "$filtered_sheet")

	if [[ $line_count -le 1 ]]; then
  		echo "ERROR: no entries for sample '$sample_name' in sample sheet. Please check your sampleSheet input." >&2
  		continue
	fi

	# skip if already demuxed
	# if ls "$thisOut/${sample_name}*${sample_name}_R1.fastq.gz" 1>/dev/null 2>&1 || ls "$thisOut/${sample_name}*${sample_name}_R2.fastq.gz" 1>/dev/null 2>&1; then
	#   echo "  Cogent demuxed already. Skipping."
	#   continue
	# fi

	# ensure read1 and read2 inputs exist
	for f in "$read1" "$read2"; do
	  if [[ ! -f "$f" ]]; then
	    echo "ERROR: Input $f missing" >&2
	    exit 1
	  fi
	done

	# #Testing 
	# echo "Running test.lsf"
	# sed \
	# 	-e "s%__THISOUT__%${thisOut}%g" \
	# 	-e "s%__SAMPLENAME__%${sample_name}%g" \
	# 	/sc/arion/work/penan08/3_cogent/test.lsf | bash
	# echo "================================"

	echo " Running cogent demux "
	sed \
	    -e "s%__READ1__%${read1}%g" \
	    -e "s%__READ2__%${read2}%g" \
	    -e "s%__SAMPLE_SHEET__%${filtered_sheet}%g" \
	    -e "s%__OUTDIR__%${thisOut}%g" \
	    -e "s%__JOB_NAME__%cogentDemux_${sample_name}%g" \
	    run_cogent_demux.lsf | bsub
	echo "================================"


done