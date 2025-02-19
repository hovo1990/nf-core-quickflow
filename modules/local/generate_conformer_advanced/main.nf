
//-- * Example: https://github.com/nf-core/sarek/blob/5cc30494a6b8e7e53be64d308b582190ca7d2585/modules/nf-core/gawk/main.nf#L6
process generateConformerAdvanced{


    label 'low_cpu'


    publishDir "${params.outdir}/stage1_generate_conformers", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    // container "/home/hovakim/GitSync/quick.sif"

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
        path(csv_input)

    output:
        path("*.xyz")


    script:
        def i_version=1
    """
        python ${projectDir}/bin/generateConformerAdvanced.py \
                                                        --input=${csv_input} \
                                                        --cachedir=${launchDir}/customCache/1_conformers
    """
}


