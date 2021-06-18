#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOFREQ_CALLPARALLEL } from '../../../../software/lofreq/callparallel/main.nf' addParams( options: [:] )

workflow test_lofreq_callparallel {
    
    input = [ [ id:'test' ], // meta map
              file('/home/AD/rbhuller/new/modules/output/lofreq/test_indelqual.bam', checkIfExists: true) ]

    fasta = file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)
    
    LOFREQ_CALLPARALLEL ( input, fasta )
}
