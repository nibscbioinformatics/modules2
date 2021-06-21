// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process MUSCLE {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::muscle=3.8.1551" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/muscle:3.8.1551--h7d875b9_6"
    } else {
        container "quay.io/biocontainers/muscle:3.8.1551--h7d875b9_6"
    }

    input:
    tuple val(meta), path(fasta)

    output:
    path "*.afa" ,  optional: true, emit: align_fasta
    path "*.phyi" , optional: true, emit: phyi
    path "*.clw"  , optional: true, emit: clustalw
    path "*.fasta", optional: true, emit: fasta
    path "*.html" , optional: true, emit: html
    path "*.msf"  , optional: true, emit: msf_format
    path "*.txt"  , optional: true, emit: log
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    muscle \\
        $options.args \\
        -in ${fasta} \\
        -out ${prefix}_muscle_multiple_alignment.afa \\
        -phyiout ${prefix}_muscle_multiple_alignment.phyi \\
        -clwout ${prefix}_muscle_multiple_alignment.clw \\
        -htmlout ${prefix}_muscle_multiple_alignment.html \\
        -fastaout ${prefix}_muscle_multiple_alignment.fasta \\
        -loga ${prefix}_muscle_multiple_alignment.log.txt
    muscle -version |  sed 's/^MUSCLE v//; s/by.*\$//'  > ${software}.version.txt
    """
}

