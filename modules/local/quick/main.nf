
process quickGPU{

    publishDir "${params.outdir}/stage3_quick_out", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    // container "/home/hovakim/GitSync/quick.sif"

    if ( workflow.containerEngine == 'singularity' && params.singularity_use_local_file  ) {
        container "${params.singularity_local_container}"
        containerOptions " --nv"
    }
    else {
        container "${params.container_link}"
    }


    // container "${params.singularity_local_container}"
    // containerOptions " --nv"

    label "process_gpu"


    input:
        path(input)

    output:
        tuple path("${input.simpleName}.out"), path("${input.simpleName}.molden")


    script:
        def i_version=1
    """
        quick.cuda ${input}
    """
}




process quickCPU{

    publishDir "${params.outdir}/stage3_quick_out", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    // container "/home/hovakim/GitSync/quick.sif"

    if ( workflow.containerEngine == 'singularity' && params.singularity_use_local_file  ) {
        container "${params.singularity_local_container}"
    }
    else {
        container "${params.container_link}"
    }


    // container "${params.singularity_local_container}"
    // containerOptions " --nv"

    label "process_full"


    input:
        path(input)

    output:
        path("${input.simpleName}.out")
        path("${input.simpleName}.molden"),  optional: true
        path("${input.simpleName}.json"),  optional: true


    script:
        def i_version=1
    """
        #mpirun -np ${task.cpus} --bind-to core quick.MPI ${input}
        quick ${input}
    """
}