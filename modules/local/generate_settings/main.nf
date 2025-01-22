
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
        containerOptions " --gpus all"
    }



    label "process_low"


    // input:
    //     path(input)

    output:
        stdout


    script:
        def i_version=2
        def hamiltonian = "${params.hamiltonian}"
        def dft_method = "${params.dft_method}"
        def basis = "${params.basis}"

        def scf_cutoff= "${params.scf_cutoff}"
        def scf_denserms ="${params.scf_denserms}"

        def charge="${params.charge}"
        def mult="${params.mult}"

        def gradient="${params.gradient}"
        def dipole ="${params.dipole}"
        def optimize="${params.optimize}"
        def export ="${params.export}"

    """
        python ${projectDir}/bin/generateSettings.py   --hamiltonian="${hamiltonian}" \
                                                        --dft_method="${dft_method}" \
                                                        --basis="${basis}" \
                                                        --scf_cutoff="${scf_cutoff}" \
                                                        --scf_denserms="${scf_denserms}" \
                                                        --charge="${charge}" \
                                                        --mult="${mult}" \
                                                        --gradient="${gradient}" \
                                                        --dipole="${dipole}" \
                                                        --optimize="${optimize}" \
                                                        --export="${export}"




    """
}
