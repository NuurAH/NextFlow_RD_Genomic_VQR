process fastP {

    label 'process_single'

    container 'staphb/fastp:1.1.0'

    // adding variable names to the data

    // Adding a tag for process identification
    tag "$sample_id"

    // Output directory for results
    publishDir("$params.outdir/fastP", mode: "copy")

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("fastP_${sample_id}/*trimmed.fastq.gz")

    script:
    """
    echo "Running fastp"

    mkdir -p fastP_${sample_id}
    cd fastP_${sample_id}
    # Check the number of files in reads and run fastqc accordingly
    if [ -f "../${reads[0]}" ] && [ -f "../${reads[1]}" ]; then
        fastp -i ../${reads[0]} -I ../${reads[1]} -o ${sample_id}_1_trimmed.fastq.gz -O ${sample_id}_2_trimmed.fastq.gz    
    elif [ -f "${reads[0]}" ]; then
        fastp -i ../${reads[0]} -o ${sample_id}_trimmed.fastq.gz 
    else
        echo "No valid read files found for sample ${sample_id}"
        exit 1
    fi
    
    echo "fastp complete"

    """
    
}