# cellgeni/scanpy/aggregate

## Summary

Runs pseudobulk aggregation on a single-cell AnnData object using `scanpy.get.aggregate`. Cells are grouped by one or more categorical columns and summarised with one or more aggregation functions, each written as a separate layer in the output AnnData.

## Get started

Include this module in your Nextflow pipeline:

```nextflow
include { SCANPY_AGGREGATE } from 'cellgeni/scanpy/aggregate'
```

### Inputs

- `tuple val(meta), path(h5ad)`
  - `meta`: sample metadata map (expects an `id` key; used for tagging and default output prefixing)
  - `h5ad`: input AnnData object in `.h5ad` format
- `val func`: aggregation function(s) — one or more of `sum`, `mean`, `var`, `count_nonzero`, `median` (space-separated when multiple)
- `val by`: obs/var column key(s) to group by (space-separated when multiple)
- `val axis`: axis on which to find the group-by column — `obs` or `var`

### Outputs

- `h5ad`: `tuple val(meta), path("*.h5ad")` (aggregated AnnData object)
- `versions`: `path("versions.yml")` (tool/package versions captured at runtime)

### Parameters

This module supports passing additional arguments to `aggregate.py` via `task.ext.args`.

When running the module directly with `nextflow module run`, set these at the command line using Nextflow "process options":

- `-process.ext.args='<AGGREGATE_ARGS>'`
- `-process.ext.prefix='<SAMPLE_PREFIX>'` (optional; defaults to `${meta.id}`)

#### Additional arguments

These are the supported arguments you can include in `ext.args`:

- `--mask` (optional): key to a boolean obs/var column to use as a mask before aggregating.
- `--dof` (optional, default `1`): degrees of freedom for variance calculation.
- `--layer` (optional): key of the AnnData layer to use for aggregation instead of `X`.
- `--obsm` (optional): key of `adata.obsm` to use for aggregation instead of `X`.
- `--varm` (optional): key of `adata.varm` to use for aggregation instead of `X`.

Notes:

- `--output` and the positional input path are handled by the module wrapper and do not need to be provided in `ext.args`.
- `--by`, `--func`, and `--axis` are provided as dedicated Nextflow inputs, not via `ext.args`.

#### Full `nextflow module run` example

```bash
nextflow module run cellgeni/scanpy/aggregate \
  --meta.id pbmc_10k \
  --h5ad /path/to/pbmc10k.h5ad \
  --func sum \
  --by celltype \
  --axis obs \
  -process.ext.prefix=pbmc_10k \
  -process.ext.args='--layer counts --dof 0'
```

## Dependencies

This module runs inside the container `community.wave.seqera.io/library/scanpy:1.12.1--72e13de137afcded`.

## License

MIT
