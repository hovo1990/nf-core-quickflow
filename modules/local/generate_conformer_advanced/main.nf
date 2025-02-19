
//-- * Example: https://github.com/nf-core/sarek/blob/5cc30494a6b8e7e53be64d308b582190ca7d2585/modules/nf-core/gawk/main.nf#L6
process generateConformerAdvanced{


    label 'low_cpu'


    publishDir "${params.outdir}/stage2_generate_conformers", mode: 'copy', overwrite: true
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



    input:
        tuple path(settings_inp), path(csv_input)

    output:
        path("${csv_input.simpleName}_modified.csv")


    script:
        def i_version=2
    """
        python ${projectDir}/bin/generateConformerAdvanced.py \
                                                        --input=${csv_input} \
                                                        --settings=${settings_inp} \
                                                        --cachedir=${workDir}/customCache \
                                                        --output="${csv_input.simpleName}_modified.csv"
    """
}


