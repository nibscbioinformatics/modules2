#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { HUMANN } from '../../../software/humann/main.nf' addParams( options: [:] )
include { BOWTIE2_BUILD } from '../../../software/bowtie2/build/main.nf' addParams( options: [:] )
include { BOWTIE2_ALIGN } from '../../../software/bowtie2/align/main.nf' addParams( options: [:] )

workflow test_humann {
    
    input = [ [ id:'test' ], // meta map
              file("/home/AD/rbhuller/tmp/input/demo.fastq.gz", checkIfExists: true) ]

    chocophlan_db = channel.fromPath('/home/AD/rbhuller/tmp/humann_dbs/chocophlan', checkIfExists: true)
    uniref_db     = channel.fromPath('/home/AD/rbhuller/tmp/humann_dbs/uniref', checkIfExists: true)
    
    HUMANN ( input, chocophlan_db, uniref_db )
}
