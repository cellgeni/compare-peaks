/*
 * Module: cellgeni/anndata/concatondisk
 */

process ANNDATA_CONCATONDISK {
    tag "${meta.id}"
    container 'community.wave.seqera.io/library/pip_anndata:61345258b0b4dfd2'

    input:
    tuple val(meta), path(h5ad)
    val axis

    output:
    tuple val(meta), path("*.h5ad"), emit: "h5ad"
    path "versions.yml"           , emit: versions

    script:
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    concatondisk.py \
        ${h5ad} \
        --axis ${axis} \
        --keys ${meta.id} \
        --output combined.h5ad \
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$( python --version 2>&1 | awk '{print \$2}' )
        anndata: \$( python -c "import anndata; print(anndata.__version__)" )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch combined.h5ad

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$( python --version 2>&1 | awk '{print \$2}' )
        anndata: \$( python -c "import anndata; print(anndata.__version__)" )
    END_VERSIONS
    """
}
