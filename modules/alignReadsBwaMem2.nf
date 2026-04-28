/*
 * Align reads to the indexed genome
 */
process alignReadsBwaMem2 {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container 'ahnuuur/bwa-mem2:2.3.1'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)   // reads is a tuple of paths for paired-end reads
    path requiredIndexFiles

    output:
    tuple val(sample_id), file("${sample_id}.bam")

    script:
    """
    # Auto-detect BWA index
    INDEX=\$(find -L ./ -name "*.amb" | sed 's/\\.amb\$//')

    echo "Running Align Reads"
    echo "\$INDEX"

    if [ -f "${reads[0]}" ]; then
        if [ -f "${reads[1]}" ]; then
            # Paired-end mode
            bwa-mem2 mem \
            -t ${task.cpus} \
            -K 100000000 \
            -M \
            -R "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:illumina" \
            \$INDEX ${reads[0]} ${reads[1]} | samtools view -b - > ${sample_id}.bam
        else
            # Single FASTQ mode
            bwa-mem2 mem \
            -t ${task.cpus} \
            -K 100000000 \
            -M \
            -R "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:illumina" \
            \$INDEX ${reads[0]} | samtools view -b - > ${sample_id}.bam      
        fi
    else
        echo "Error: Read file ${reads[0]} does not exist for sample ${sample_id}."
        exit 1
    fi

    echo "Alignment complete"
    """
}
