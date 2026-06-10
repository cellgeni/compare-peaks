/*
 * Module: cellgeni/anndata/concat
 */

process ANNDATA_CONCAT {
    tag "${meta.id}"
    container 'community.wave.seqera.io/library/pip_anndata:61345258b0b4dfd2'

    input:
    tuple val(meta), path(h5ad, stageAs: "inputs/*/*")
    val axis

    output:
    tuple val(meta), path("*.h5ad"), emit: h5ad
    path "versions.yml"           , emit: versions

    script:
    def args = task.ext.args ?: ""
    """
    concat.py \
        ${h5ad} \
        --axis ${axis} \
        --output combined.h5ad \
        --keys ${meta.id} \
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$( python --version 2>&1 | awk '{print \$2}' )
        anndata: \$( python -c "import anndata; print(anndata.__version__)" )
    END_VERSIONS
    """

    stub:
    """
    touch combined.h5ad

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$( python --version 2>&1 | awk '{print \$2}' )
        anndata: \$( python -c "import anndata; print(anndata.__version__)" )
    END_VERSIONS
    """
}
