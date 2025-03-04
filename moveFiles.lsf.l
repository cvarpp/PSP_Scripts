#!/bin/bash
#BSUB -J gettingFiles 
#BSUB -P acc_pMorpheus
#BSUB -q express
#BSUB -n 1
#BSUB -R rusage[mem=8000]
#BSUB -W 01:00
#BSUB -o ./%Jstdout
#BSUB -eo ./%Jstderr
#BSUB -L /bin/bash

# Define the source parent directory containing the subdirectories
SOURCE_DIR="/sc/arion/projects/pMorpheus/2025_02_27_rnaseq/AN00023282"

# Define the base destination directory
DEST_DIR="/sc/arion/projects/pMorpheus/noah/2025_02_27_rnaseq/AN00023282/"

# Loop through each subdirectory in the source directory
for dir in "$SOURCE_DIR"/*; do
    # Extract the base name of the directory (without the trailing slash)
    DIR_NAME=$(basename "$dir")
    
    # Define the source file path
    SOURCE_FILE_1="${dir}_1.fastq.gz"
    SOURCE_FILE_2="${dir}_2.fastq.gz"
    SOURCE_FILE_3="${dir}.md5"

    # Check if the file exists in the current directory
    if [[ -f "$SOURCE_FILE_1" ]]; then
        # Create the destination directory if it doesn't exist
        mkdir -p "$DEST_DIR/$DIR_NAME"
        
        # Define the destination file path
        DEST_FILE_1="$DEST_DIR/$DIR_NAME/${DIR_NAME}_1.fastq.gz"

        # move the file to the destination
        mv "$SOURCE_FILE_1" "$DEST_FILE_1"

	echo "Moved $SOURCE_FILE_1 to $DEST_FILE_1"

    else
        echo "File $SOURCE_FILE_1 not in $dir"
    fi

    if [[ -f "$SOURCE_FILE_2" ]]; then
	    #Define destination file path 
        DEST_FILE_2="$DEST_DIR/$DIR_NAME/${DIR_NAME}_2.fastq.gz"

	    #Move the file to the destination

        mv "$SOURCE_FILE_2" "$DEST_FILE_2"
        
	    echo "Moved $SOURCE_FILE_2 to $DEST_FILE_2"

     else
	    echo "File $SOURCE_FILE_2 not in $dir"
     fi

    if [[ -f "$SOURCE_FILE_3" ]]; then 

        #Define the desintatino file path 
        DEST_FILE_3=DEST_FILE_2="$DEST_DIR/$DIR_NAME/${DIR_NAME}.md5"


        #Move to the file to the destination 

        mv "$SOURCE_FILE_3" to "$DEST_FILE_3"

        echo "Moved $SOURCE_FILE_3 to $DEST_FILE_3"
    else 
        echo "FIle $SOURCE_FILE_3 not in $dir" 
    fi

done

echo "Done partner!