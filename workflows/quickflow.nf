/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

params.container_link = "docker.io/hgrabski/quick:latest"





include { paramsSummaryMap       } from 'plugin/nf-schema'

include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_quickflow_pipeline'



//-- * Custom modules
include { generateConformer } from '../modules/local/generate_conformer'

include { generateSettings } from '../modules/local/generate_settings'


include { prepareInput } from '../modules/local/prepare_input'


include { quickGPU } from '../modules/local/quick'

include { quickCPU } from '../modules/local/quick'



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
    // conformers.view()

    //-- * Stage 2: generate settings command line
    settings = generateSettings(conformers)
    // settings.view()

    // //-- * Stage 3: Prepend parameters for quick
    // //-- ? Sort of default: DFT B3LYP BASIS=6-311+G(2d,p) cutoff=1.0e-10 denserms=1.0e-6  GRADIENT DIPOLE OPTIMIZE EXPORT=MOLDEN
    
    to_do = settings
    // to_do.view()
    preped_input = prepareInput(to_do)


    // // //-- * Stage 4: Quick Calculation
    // // //-- ? Manual: https://quick-docs.readthedocs.io/en/latest/user-manual.html
    // // //-- ? Guide: https://quick-docs.readthedocs.io/en/latest/hands-on-tutorials.html
    // // //-- ? https://www.reddit.com/r/comp_chem/comments/1f8cavw/how_can_i_visualise_molecular_orbitals_from/
    // // //-- ? GPU enabled by default, if not run on CPU


    //-- TODO whre to modify https://github.com/hovo1990/QUICK/blob/master/src/modules/quick_molden_module.f90
    //-- TODO add QCSchema export in quick
    if ( params.useGPU ) {
        quick_out = quickGPU(preped_input)
        // quick_out.view()
    } 
    else {
        //-- ! Gives segmentation fault, really
        //-- TODO discuss with Andy
        quick_out = quickCPU(preped_input)
    }

    




    //-- * Stage 4: Validate calculation output files
    //-- * fake smiles that cause error: Normal Termination. water, limit iteration.
    //-- * cutoff=1.0e-6 denserms=1.0e-8  it won't converge

    //-- * Stage 5: Generate report, html file view, dashboard, summary of jobs, parameter input, 
    //-- * What jobs were exectured, how long it took, statistics, resource usage, if available
    //-- ? qcengine 
    //-- ? https://github.com/SCM-NV/qmflows/tree/master/src/qmflows/examples

    //-- * Stage 6: Generate  QCSchema, fortran or c++ 
    //-- ? Resource: https://github.com/MolSSI/QCSchema
    //-- ? Resource: https://molssi-qc-schema.readthedocs.io/en/latest/index.html#

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
