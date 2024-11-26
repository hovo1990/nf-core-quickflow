
process generateSettings{

    // publishDir "${params.outdir}/stage2_prep_input", mode: 'copy', overwrite: true
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


    // input:
    //     path(input)

    output:
        stdout


    script:
        def i_version=1
        def hamiltonian = "${params.hamiltonian}"
        def dft_method = ${params.dft_method}
        
    """
        python ${projectDir}/bin/generateSettings.py   --hamiltonian=${hamiltonian} 
    """
}
