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
    path "*.afa"                  , emit: aligned_fasta
    path "*.phyi" , optional: true, emit: phyi
    path "*.phys" , optional: true, emit: phys
    path "*.clw"  , optional: true, emit: clustalw
    path "*.html" , optional: true, emit: html
    path "*.msf"  , optional: true, emit: msf
    path "*.txt"                  , emit: log
    path "*.version.txt"          , emit: version

    script:
    def software    = getSoftwareName(task.process)
    def prefix      = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def clw_out     = options.args.contains('-clw') ? "-clwout ${prefix}_muscle_msa.clw" : ''
    def msf_out     = options.args.contains('-msf') ? "-msfout ${prefix}_muscle_msa.msf" : ''
    def phys_out    = options.args.contains('-phys') ? "-physout ${prefix}_muscle_msa.phys" : ''
    def phyi_out    = options.args.contains('-phyi') ? "-phyiout ${prefix}_muscle_msa.phyi" : ''
    def html_out    = options.args.contains('-html') ? "-htmlout ${prefix}_muscle_msa.html" : ''
    """
    muscle \\
        $options.args \\
        -in ${fasta} \\
        -out ${prefix}_muscle_msa.afa \\
        $clw_out \\
        $msf_out \\
        $phys_out \\
        $phyi_out \\
        $html_out \\
        -loga ${prefix}_muscle_msa.log.txt
    muscle -version |  sed 's/^MUSCLE v//; s/by.*\$//'  > ${software}.version.txt
    """
}
