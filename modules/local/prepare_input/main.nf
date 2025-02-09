
process prepareInput{

    label 'low_cpu'

    cpus  1
    memory  '1 GB'

    beforeScript "hostname"
    publishDir "${params.outdir}/stage3_prep_input", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    if ( workflow.containerEngine == 'singularity' && params.singularity_use_local_file  ) {
        container "${params.singularity_local_container}"
        // containerOptions " --nv"
    }
    else if (workflow.containerEngine == 'singularity' ){
        container "${params.container_link}"
    }
    else {
        container "${params.container_link}"
        // containerOptions " --gpus all"
    }



    label "process_low"


    input:
        tuple path(input), path(mainArg)

    output:
        path("${input.simpleName}_prep.xyz")


    script:
        def i_version=4
    """
        cp ${input} ${input.simpleName}_prep.xyz
        mainArgTODO=\$(<${mainArg})
        sed -i "1s/.*/\${mainArgTODO}/" ${input.simpleName}_prep.xyz
    """
}
