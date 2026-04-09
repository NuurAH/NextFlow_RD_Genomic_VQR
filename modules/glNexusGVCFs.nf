process combineGVCFs {
    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }
    container 'ahnuuur/gl-nexus:1.4.1'
    tag "${sample_ids.join('_')}" // Add a tag based on the sample IDs

    input:
    tuple val(sample_ids), path(gvcf_files), path(gvcf_index_files)
    path indexFiles

    output:
    tuple val("${sample_ids.join('_')}"), file("*_combined.vcf.gz"), file("*_combined.vcf.gz.tbi")
    script:
    def merged_sample_id = "${sample_ids.join('_')}"
    def gvcf_files_args = gvcf_files.collect { file -> "-V ${file}" }.join(' ')

    """
    echo "Combining GVCFs for samples: ${gvcf_files.collect { it.baseName }.join(', ')}"
    if [[ -n ${params.genome_file} ]]; then
        genomeFasta=\$(basename ${params.genome_file})
    else
        genomeFasta=\$(find -L . -name '*.fa')
    fi

    glnexus_cli --config DeepVariant *.g.vcf.gz >  ${merged_sample_id}_combined.vcf \

    bcftools view -Oz -o ${merged_sample_id}_combined.vcf.gz ${merged_sample_id}_combined.vcf &&\
    bcftools index -t ${merged_sample_id}_combined.vcf.gz
    """
}

