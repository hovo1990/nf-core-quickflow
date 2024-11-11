
process prepareInput{

    publishDir "${params.outdir}/stage2_prep_input", mode: 'copy', overwrite: true
    // container  "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_use_local_file ?
    //         ${params.singularity_local_container} :
    //         'biocontainers/gawk:5.3.0' }"

    // container "/home/hovakim/GitSync/quick.sif"
    container "${params.singularity_local_container}"


    label "process_low"


    input:
        path(input)

    output:
        path("${input.simpleName}_prep.xyz")


    script:
        def i_version=2
    """
        cp ${input} ${input.simpleName}_prep.xyz
        sed -i '1s/.*/DFT B3LYP BASIS=6-311+G(2d,p) cutoff=1.0e-9 denserms=1.0e-6  zmake GRADIENT DIPOLE/' ${input.simpleName}_prep.xyz 
    """
}
