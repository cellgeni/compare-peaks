# cellgeni/anndata/concat

## Summary

Concatenates multiple AnnData objects in memory using `anndata.concat`. Unlike `anndata.experimental.concat_on_disk`, all input objects are loaded into memory — use the `concatondisk` module for large datasets.

## Get started

Include this module in your Nextflow pipeline:

```nextflow
include { ANNDATA_CONCAT } from 'cellgeni/anndata/concat'
```

### Inputs

- `tuple val(meta), path(h5ad)`
  - `meta`: sample metadata map (expects an `id` key; used for tagging and default output prefixing)
  - `h5ad`: one or more input AnnData objects in `.h5ad` format
- `val axis`: axis to concatenate along — `obs` or `var`

### Outputs

- `h5ad`: `tuple val(meta), path("*.h5ad")` (concatenated AnnData object written as `${meta.id}_concat.h5ad`)
- `versions`: `path("versions.yml")` (tool/package versions captured at runtime)

### Parameters

This module supports passing additional arguments to `concat.py` via `task.ext.args`.

When running the module directly with `nextflow module run`, set these at the command line using Nextflow "process options":

- `-process.ext.args='<CONCAT_ARGS>'`
- `-process.ext.prefix='<SAMPLE_PREFIX>'` (optional; defaults to `${meta.id}`)

#### Additional arguments

These are the supported arguments you can include in `ext.args`:

- `--merge` (optional): how to select elements not aligned to the concatenation axis. Choices: `same`, `unique`, `first`, `only`.
- `--uns-merge` (optional): how to select `.uns` elements. Choices: `same`, `unique`, `first`, `only`.
- `--label` (optional): obs/var column name in which to store batch labels.
- `--keys` (optional): names for each input object, used for the label column or index. Must match the number of input files.
- `--index-unique` (optional): delimiter to make the index unique: `{orig_idx}{delimiter}{key}`.
- `--fill-value` (optional): fill value for introduced indices when `--join=outer`.
- `--pairwise` (optional flag): include pairwise elements along the concatenated dimension.
- `--force-lazy` (optional flag): lazily concatenate using dask even when eager concatenation is possible.

Notes:

- `--output` and the positional input paths are handled by the module wrapper and do not need to be provided in `ext.args`.
- `--axis` is provided as a dedicated Nextflow input, not via `ext.args`.
- `--keys` is automatically set to `meta.id` by the module wrapper. Override it via `ext.args` only if you need per-file keys different from the sample ID.

#### Full `nextflow module run` example

```bash
nextflow module run cellgeni/anndata/concat \
  --meta.id combined \
  --h5ad "/path/to/sample_*.h5ad" \
  --axis obs \
  -process.ext.args='--join inner --merge same --label batch'
```

## Dependencies

This module runs inside the container `community.wave.seqera.io/library/pip_anndata:61345258b0b4dfd2`.

## License

MIT
