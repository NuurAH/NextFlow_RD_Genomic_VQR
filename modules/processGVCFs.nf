process combineGVCFs {
    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }
    container 'variantvalidator/gatk4:4.3.0.0'
    tag "${sample_ids.join('_')}" // Add a tag based on the sample IDs

    input:
    tuple val(sample_ids), path(gvcf_files), path(gvcf_index_files)
    path indexFiles

    output:
    tuple val("${sample_ids.join('_')}"), file("*_combined.vcf"), file("*_combined.vcf.idx")

    script:
    def merged_sample_id = "${sample_ids.join('_')}"
    def gvcf_files_args = gvcf_files.collect { file -> "-V ${file}" }.join(' ')

    """
    echo "Combining GVCFs for samples: ${gvcf_files.collect { it.baseName }.join(', ')}"
    
    genomeFasta=\$(find -L . -name '*.fa')
   
    # Ensure dictionary exists
    if [[ -e "\${genomeFasta}.dict" ]]; then
        mv "\${genomeFasta}.dict" "\${genomeFasta%.*}.dict"
    fi

    gatk CombineGVCFs -R "\${genomeFasta}"\
        ${gvcf_files_args} \
        -O ${merged_sample_id}_combined.vcf
    """
}

process genotypeGVCFs {
    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }
    container 'variantvalidator/gatk4:4.3.0.0'
    tag "$combined_sample_id"

    input:
    tuple val(combined_sample_id), file(combined_gvcf), file(combined_gvcf_idx)
    path indexFiles

    output:
    tuple val(combined_sample_id), file("*_genotyped.vcf"), file("*_genotyped.vcf.idx")

    script:
    def merged_sample_id = combined_gvcf.baseName

    """

    echo "Genotyping combined GVCF: ${combined_gvcf.baseName}"
    
    genomeFasta="\$(find -L . -name '*.fa')" 


    echo "Genome File: \${genomeFasta}"

    # Rename the dictionary file to the expected name if it exists
    if [[ -e "\${genomeFasta}.dict" ]]; then
        mv "\${genomeFasta}.dict" "\${genomeFasta%.*}.dict"
    fi

    if [[ ${params.process_GVCFs == "glNexus"} ]]; then
        gatk IndexFeatureFile \
        -I ${combined_gvcf} -O ${combined_gvcf}.idx && \
        ln -sf ${combined_gvcf}.idx ${combined_gvcf_idx}
    fi



    gatk GenotypeGVCFs -R "\${genomeFasta}" \
        -V ${combined_gvcf} \
        -O ${merged_sample_id}_genotyped.vcf

    """
}