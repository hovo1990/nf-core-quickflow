
//-- * Example: https://github.com/nf-core/sarek/blob/5cc30494a6b8e7e53be64d308b582190ca7d2585/modules/nf-core/gawk/main.nf#L6
process generateConformer{

    publishDir "${params.outDir}/stage1_generate_conformers", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    // container "/home/hovakim/GitSync/quick.sif"
    container "${params.singularity_local_container}"


    label "process_low"


    input:
        tuple val(id), val(smiles), val(name)

    output:
        path("${name}_${smiles}.xyz")


    script:
        def i_version=1
    """
        echo ${id}
    """
}

