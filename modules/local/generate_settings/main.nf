
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
        def dft_method = "${params.dft_method}"
        def basis = "${params.basis}"
        def libxc_bp86 = "${params.libxc_BP86}"
        def libxc_b97 = "${params.libxc_B97}"
        def libxc_b97_gga1 = "${params.libxc_B97_GGA1}"
        def libxc_pw91 = "${params.libxc_PW91}"
        def libxc_olyp= "${params.libxc_OLYP}"
        def libxc_o3lyp = "${params.libxc_O3LYP}"
        def libxc_pbe= "${params.libxc_PBE}"
        def libxc_revpbe= "${params.libxc_REVPBE}"
        def libxc_pbe0= "${params.libxc_PBE0}"

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
                                                        --libxc_bp86="${libxc_bp86}" \
                                                        --libxc_b97_gga1="${libxc_b97_gga1}" \
                                                        --libxc_pw91="${libxc_pw91}" \
                                                        --libxc_olyp="${libxc_olyp}" \
                                                        --libxc_o3lyp="${libxc_o3lyp}" \
                                                        --libxc_pbe="${libxc_pbe}" \
                                                        --libxc_revpbe="${libxc_revpbe}" \
                                                        --libxc_pbe0="${libxc_pbe0}" \
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
