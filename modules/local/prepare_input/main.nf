
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
        tuple path(input), val(mainArg)

    output:
        path("${input.simpleName}_prep.xyz")


    script:
        def i_version=4
    """
        cp ${input} ${input.simpleName}_prep.xyz
        sed -i '1s/.*/${mainArg}/' ${input.simpleName}_prep.xyz 
    """
}
