# PSP_Scripts
LSF scripts and more

| Script | Description |
|---|---|
| bam_sort_wig.sh | LSF script convert bam files to bigWig files| For easier viewing in IGB or IGV. |
| bowtie2_build.lsf| Build a bowtie2 index to run bowtie2 alignment tool. |
| bowtie2_pairedEnd.lsf| Conduct bowtie2 paired-end alignment. Can also use local option, but run specific. See bowtie2 documentation |
| bowtie_PAIREND.lsf| Conduct BOWTIE paire-end alignment. v1 of bowtie alignment tool, more stringent. Use local alignment settings if you want end-to-end (standard). |
| minimap_pairedEndl.lsf | Conduct minimap paired-end alignment using minimap2 aligner.|
| moveFiles.lsf | Move files (e.i., sample_1.fastq.gz) and into sample directories. Check to ensure naming conventions are compatible.      |
| star_build.lsf | Create a STAR index for STAR aligner. |
| star_pairedEnd.lsf | Conduct STAR paired-end alignment using STAR aligner. |
| wig_to_tsv_low_mem.py | Python script that can be used to generate tsv files from bigWig files to a reference (i.e., FASTA) that was aligned to. 
| Somatic Mutation Pipeline | A pipeline that allows you to detect somatic mutations between a "normal" and "experimental" group. |

