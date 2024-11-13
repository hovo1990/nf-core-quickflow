/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

params.container_link = "biocontainers/gawk:5.3.0"





include { paramsSummaryMap       } from 'plugin/nf-schema'

include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_quickflow_pipeline'



//-- * Custom modules
include { generateConformer } from '../modules/local/generate_conformer'

include { prepareInput } from '../modules/local/prepare_input'


include { quickGPU } from '../modules/local/quick'




/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow QUICKFLOW {

    take:
    ch_compounds_input // channel: ch_compounds_input read in from --input
    main:

    ch_versions = Channel.empty()
    
    // println("Hello world!!!!!!")

    // ch_compounds_input.view()



    //-- * Stage 1: Prepare conformers and save xyz
    conformers = generateConformer(ch_compounds_input)

    //-- * Stage 2: Prepend parameters for quick
    preped_input = prepareInput(conformers)


    //-- * Stage 3: Quick Calculation
    //-- ? Manual: https://quick-docs.readthedocs.io/en/latest/user-manual.html
    //-- ? Guide: https://quick-docs.readthedocs.io/en/latest/hands-on-tutorials.html
    //-- ? https://www.reddit.com/r/comp_chem/comments/1f8cavw/how_can_i_visualise_molecular_orbitals_from/
    quick_out = quickGPU(preped_input)
    quick_out.view()

    //-- * Stage 4: Validate calculation 

    //-- * Stage 5: Generate report 

    //-- * Stage 6: Generate QSSchema  compatible output

    //-- * Stage 7: Generate DeePMD compatible output



    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  + 'pipeline_software_' +  ''  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
