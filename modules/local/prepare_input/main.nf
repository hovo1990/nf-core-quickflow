
process prepareInput{

    publishDir "${params.outdir}/stage2_prep_input", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    if ( workflow.containerEngine == 'singularity' && params.singularity_use_local_file  ) {
        container "${params.singularity_local_container}"
        containerOptions " --nv"
    }
    else {
        container "${params.container_link}"
    }



    label "process_low"


    input:
        path(input)

    output:
        path("${input.simpleName}_prep.xyz")


    script:
        def i_version=4
    """
        cp ${input} ${input.simpleName}_prep.xyz
        sed -i '1s/.*/DFT B3LYP BASIS=${params.basis} cutoff=1.0e-10 denserms=1.0e-6  zmake GRADIENT DIPOLE OPTIMIZE EXPORT=MOLDEN/' ${input.simpleName}_prep.xyz 
    """
}
