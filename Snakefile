rule all:
    input:
        "noop.txt"

rule hisat2:
    input:
        "fastqs/{sample}_R1.fastq",
        "fastqs/{sample}_R2.fastq"
    conda:
        "hisat2_env.yaml"
    output:
        "mapped/{sample}.bam"
    shell:
        'bsub -P acc_HERVP -W 08:00 -oo logs/out.%J.txt -eo logs/err.%J.txt -J singleHisat2_%J -n 18 -q express -R "span[hosts=1]" < "hisat2 --score-min L,0,-0.14 -k 100 -x hg38 -1 {input[0]} -2 {input[1]} -p 34 | samtools view -b > mapped/{wildcards.sample}.bam"'

rule telescope:
    input:
        "mapped/{sample}.bam"
    output:
        "tele_out/{sample}-updated.bam"
    conda:
        "tele_env.yaml"
    shell:
        "./telescope_wrap.sh {wildcards.sample} hg38.HERV.gtf"
