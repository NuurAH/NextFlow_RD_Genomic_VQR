/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process indexGenome2 {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }
    container 'ahnuuur/bwa-mem2:2.3.1'


    // Publish indexed files to the specified directory
    publishDir("$params.outdir/GENOME_IDX2", mode: "copy")

    input:
    path genomeFasta

    output:
    tuple path(genomeFasta), path("${genomeFasta}.*")

    script:
    """
    echo "Running Index Genome"

    # Generate BWA index
    bwa-mem2 index "${genomeFasta}"

    # Generate samtools faidx
    samtools faidx "${genomeFasta}"

    # generate a sequence dictionary 
    picard CreateSequenceDictionary R="${genomeFasta}" O="${genomeFasta}.dict"

    echo "Genome Indexing for bwa-mem2 alignment complete." 
    
    """   

    }