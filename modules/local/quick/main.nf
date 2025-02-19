
process quickGPU{

    label 'gpu_task'

    // -- * Better debugging
    beforeScript 'hostname; nvidia-smi'




    publishDir "${params.outdir}/stage3_quick_out", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    // container "/home/hovakim/GitSync/quick.sif"

    if ( workflow.containerEngine in ['singularity', 'apptainer'] && params.singularity_use_local_file  ) {
        container "${params.singularity_local_container}"
        containerOptions " --nv"
    }
    else if (workflow.containerEngine in ['singularity', 'apptainer']){
        container "${params.container_link}"
        containerOptions " --nv"
    }
    else {
        container "${params.container_link}"
        containerOptions " --gpus all"
    }




    input:
        tuple val(ID), val(NAME), val(SMILES), path(input)

    output:
        path("${input.simpleName}.out")
        path("${input.simpleName}.molden"),  optional: true
        path("${input.simpleName}.json"),  optional: true


    script:
        def i_version=1
    """
        quick.cuda ${input}
    """
}




process quickCPU{

    label 'cpu_task'



    publishDir "${params.outdir}/stage3_quick_out", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    // container "/home/hovakim/GitSync/quick.sif"

    if ( workflow.containerEngine in ['singularity', 'apptainer'] && params.singularity_use_local_file  ) {
        container "${params.singularity_local_container}"
        // containerOptions " --nv"
    }
    else if (workflow.containerEngine in ['singularity', 'apptainer'] ){
        container "${params.container_link}"
    }
    else {
        container "${params.container_link}"
        // containerOptions " --gpus all"
    }



    input:
        tuple val(ID), val(NAME), val(SMILES), path(input)

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
