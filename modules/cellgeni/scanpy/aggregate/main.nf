/*
 * Module: cellgeni/scanpy/aggregate
 */

process SCANPY_AGGREGATE {
    tag "${meta.id}"
    container 'community.wave.seqera.io/library/scanpy:1.12.1--72e13de137afcded'
    
    input:
    tuple val(meta), path(h5ad)
    val func
    val by

    output:
    tuple val(meta), path("*.h5ad"), emit: "h5ad"
    path "versions.yml"           , emit: versions

    script:
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    aggregate.py \
        ${h5ad} \
        --by ${by} \
        --func ${func} \
        --output ${prefix}_aggregated.h5ad \
        ${args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$( python --version 2>&1 | awk '{print \$2}' )
        anndata: \$( python -c "import anndata; print(anndata.__version__)" )
        scanpy: \$( python -c "import scanpy; print(scanpy.__version__)" )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: "--func sum"
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_aggregated.h5ad

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$( python --version 2>&1 | awk '{print \$2}' )
        anndata: \$( python -c "import anndata; print(anndata.__version__)" )
        scanpy: \$( python -c "import scanpy; print(scanpy.__version__)" )
    END_VERSIONS
    """
}
