#!/usr/bin/env nextflow

genome_folders = [
    "/media/mordor/gianmarco/anaconda/envs/ncbi/bin/mags_descargados_2000/output_2000",
    "/media/mordor/gianmarco/anaconda/envs/ncbi/bin/mags_descargados_3000_20k_23k/descargado",
    "/media/mordor/gianmarco/anaconda/envs/ncbi/bin/mags_descargados_2000_24k_25k/descargado", 
    "/media/mordor/gianmarco/anaconda/envs/ncbi/bin/mags_descargados_2000_26k_27k/descargado",
    "/media/mordor/gianmarco/anaconda/envs/ncbi/bin/mags_descargados_3000_28k_30k/descargado"
]

folder_names = [
    "output-2000",
    "3000_20k-23k", 
    "2000_24k-25k",
    "2000_26k-27k",
    "3000_28k-30k"
]

params.outdir_base = "/media/mordor/gianmarco/nextflow/checkm2_analysis_total_20k-30k"

process checkm2_complete {
    cpus 32
    publishDir "${output_dir_param}", mode: 'copy', overwrite: true
    
    input:
    tuple val(genome_folder), val(output_dir_param), val(folder_num)
    
    output:
    path "*"
    
    script:
    """
    checkm2 predict \
        --threads ${task.cpus} \
        --input "${genome_folder}" \
        --extension fna \
        --output-directory . \
        --force
    """
}

workflow {
    Channel.from(genome_folders)
        .map { folder ->
            def idx = genome_folders.indexOf(folder)
            def name = folder_names[idx]
            return tuple(folder, "${params.outdir_base}_${name}", name)
        }
        .set { genome_data }
    
    checkm2_complete(genome_data)
}
