include { SCANPY_AGGREGATE as SCANPY_AGGREGATE_LVL3 } from '../modules/cellgeni/scanpy/aggregate/main.nf'
include { SCANPY_AGGREGATE as SCANPY_AGGREGATE_LVL5 } from '../modules/cellgeni/scanpy/aggregate/main.nf'
include { ANNDATA_CONCAT as ANNDATA_CONCAT_LVL3 } from '../modules/cellgeni/anndata/concat/main.nf'
include { ANNDATA_CONCAT as ANNDATA_CONCAT_LVL5 } from '../modules/cellgeni/anndata/concat/main.nf'

workflow {
    main:
    // Create a channel with h5ad files
    lvl3adata = channel.fromPath("/lustre/scratch124/cellgen/cellgeni/aljes/nf-atac/we_results/newlvl3/anndata/*/*_sharedbarcodes_atac.h5ad")
        .map { file -> 
            def sample=file.toString().split("/")[-2]
            tuple([id: sample, tag: "lvl3"], file)
        }

    lvl5adata = channel.fromPath("/lustre/scratch124/cellgen/cellgeni/aljes/nf-atac/we_results/newlvl5/anndata/*/*_sharedbarcodes_atac.h5ad")
        .map { file -> 
            def sample=file.toString().split("/")[-2]
            tuple([id: sample, tag: "lvl5"], file)
        }
    
    // Calculate pseudobulks
    SCANPY_AGGREGATE_LVL3(lvl3adata, "sum mean", "sample_id celltype", "obs")
    SCANPY_AGGREGATE_LVL5(lvl5adata, "sum mean", "sample_id celltype", "obs")

    // Concatenate pseudobulks
    grouped_lvl3 = SCANPY_AGGREGATE_LVL3.out.h5ad
        .collect(sort: true, flat: false)
        .transpose()
        .collect(flat: false)
        .map { metas, files -> tuple([id: metas.collect { it -> it.id }.join(" "), tag: "lvl3"], files) }
    ANNDATA_CONCAT_LVL3(grouped_lvl3, "obs")

    grouped_lvl5 = SCANPY_AGGREGATE_LVL5.out.h5ad
        .collect(sort: true, flat: false)
        .transpose()
        .collect(flat: false)
        .map { metas, files -> tuple([id: metas.collect { it -> it.id }.join(" "), tag: "lvl5"], files) }
    ANNDATA_CONCAT_LVL5(grouped_lvl5, "obs")

    publish:
    pseudobulk = SCANPY_AGGREGATE_LVL3.out.h5ad.mix( SCANPY_AGGREGATE_LVL5.out.h5ad )
    combined_pb = ANNDATA_CONCAT_LVL3.out.h5ad.mix( ANNDATA_CONCAT_LVL5.out.h5ad )
}

output {
    pseudobulk {
        path { meta, file -> "pseudobulk/samples/${meta.tag}"}
    }
    combined_pb {
        path { meta, file -> "pseudobulk/${meta.tag}" }
    }
}