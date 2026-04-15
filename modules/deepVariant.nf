// Use newest nextflow dsl
nextflow.enable.dsl = 2

process deepVariant {
    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container 'google/deepvariant:1.10.0'

    tag "$bamFile"

    input:
    tuple val(sample_id), file(bamFile), file(bamIndex)
    path indexFiles

    output:
    tuple val(sample_id), file("*.vcf.gz"), file("*.vcf.gz.tbi")

    script:
    """
    echo "Running Deepvariant for Sample: ${bamFile}"

    if [[ -n ${params.genome_file} ]]; then
        genomeFasta=\$(basename ${params.genome_file})
    else
        genomeFasta=\$(find -L . -name '*.fa')
    fi
    /opt/deepvariant/bin/run_deepvariant \
    --model_type=WES \
    --ref=\$genomeFasta \
    --reads=${bamFile} \
    --output_vcf=tmp/${sample_id}.vcf.gz \
    --output_gvcf=${sample_id}.g.vcf.gz \
    --intermediate_results_dir=tmp \
    --num_shards=8
    """
    }