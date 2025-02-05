
process generateSettings{

    label 'low_cpu'
    publishDir "${params.outdir}/stage2_settings", mode: 'copy', overwrite: true

    beforeScript "hostname"
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
        path(input)

    output:
        tuple path(input), path("${input.simpleName}.param")


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
                                                        --export="${export}" \
                                                        --output="${input.simpleName}.param"




    """
}
