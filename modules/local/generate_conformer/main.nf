process generateConformer{

    publishDir "${params.outDir}/stage1_generate_conformers", mode: 'copy', overwrite: true

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gawk:5.3.0' :
        'biocontainers/gawk:5.3.0' }"


    input:
        tuple val(id), val(smiles), val(name)

    output:
        path("${name}_${smiles}.xyz")


    script:
        def i_version=1
    """
        ${params.scripts_folder ?: "/pro/hpc" }/pocketome/helper/stage7_struct_clean.icm -v=yes -i=${struct_file} -iseq=${sequence_file} -o=${struct_file.simpleName}_tab.csv
    """
}

