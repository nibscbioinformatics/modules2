#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
//  test data locations in nf config (will tidy before final submission :) )
// To get around metaphlan auto-download, I used the following link (https://zenodo.org/record/4629921/files/metaphlan_databases.tar.gz) to download the tar file (helpfully provided on YAML nf pipeline github wiki). I then decompressed it and supplied the path to the directory
// The DB is very large (~1.9 GB) and I'm struggling how best to work around this.... apologies for the trouble caused to get this running!

include { SAMTOOLS_VIEW } from '../../../../software/samtools/view/main.nf' addParams( options: [:] ) //metaphlan can't take bam input
include { BOWTIE2_BUILD } from '../../../../software/bowtie2/build/main.nf' addParams( options: [:] )
include { BOWTIE2_ALIGN } from '../../../../software/bowtie2/align/main.nf' addParams( options: [:] )
include { METAPHLAN3_RUN } from '../../../../software/metaphlan3/run/main.nf' addParams( options: [ 'args':'--index mpa_v30_CHOCOPhlAn_201901 --add_viruses' ] ) //database version (latest, if not supplied attempts db autodownload and fails)
include { SEQTK_SAMPLE } from '../../../../software/seqtk/sample/main.nf' addParams( options: ['args': '-a'] ) // convert to fasta

workflow test_metaphlan3_single_end {

    input = [ [ id:'test', single_end:true ], // meta map
              [ file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true) ]
            ]

//    fasta = file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)

    db    = channel.fromPath('/home/AD/mgordon/DATA/microbiome_testdata/testdata/YAMP_data/metaphlan3_sars_db', type: 'dir', checkIfExists: true)

    METAPHLAN3_RUN ( input, db )
}

workflow test_metaphlan3_paired_end {

    input = [ [ id:'test', single_end:false ], // meta map
              [ file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true),
                file(params.test_data['sarscov2']['illumina']['test_2_fastq_gz'], checkIfExists: true) ]
            ]

    db    = channel.fromPath("/home/AD/mgordon/DATA/microbiome_testdata/testdata/YAMP_data/mini_metaphlan_databases", type: 'dir', checkIfExists: true)

    METAPHLAN3_RUN ( input, db )
}

workflow test_metaphlan3_sam {

    input = [ [ id:'test'], // meta map
              [ file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true) ]
            ]

    db    = channel.fromPath("/home/AD/mgordon/DATA/microbiome_testdata/testdata/YAMP_data/mini_metaphlan_databases", type: 'dir', checkIfExists: true)

    SAMTOOLS_VIEW ( input )
    METAPHLAN3_RUN ( SAMTOOLS_VIEW.out.bam, db )
}

workflow test_metaphlan3_fasta {

    input = [ [ id:'test', single_end:true], // meta map
            //  [ file(params.test_data['sarscov2']['genome']['transcriptome_fasta'], checkIfExists: true) ]
                [ file("/home/AD/mgordon/DATA/microbiome_testdata/testdata/YAMP_data/test_data/transcriptome.fasta", checkIfExists: true) ]
            ]

    db    = channel.fromPath("/home/AD/mgordon/DATA/microbiome_testdata/testdata/YAMP_data/mini_metaphlan_databases", type: 'dir', checkIfExists: true)

    METAPHLAN3_RUN ( input, db )
}


workflow test_metaphlan3_bowtie2out {

    input = [ [ id:'test'], // meta map
              [ file("/home/AD/mgordon/PROJECTS/B034_NextFlow_Metagenomics/modules/tests/config/metaphlan3_testdata/toy_metagenome.bowtie2out.txt", checkIfExists: true) ]
            ]

    db    = channel.fromPath("/home/AD/mgordon/DATA/microbiome_testdata/testdata/YAMP_data/mini_metaphlan_databases", type: 'dir', checkIfExists: true )

    METAPHLAN3_RUN ( input, db )
}


