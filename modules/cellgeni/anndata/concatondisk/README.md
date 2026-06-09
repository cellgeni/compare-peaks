# cellgeni/anndata/concatondisk

## Summary

Concatenates multiple AnnData objects on disk using `anndata.experimental.concat_on_disk`. Unlike `anndata.concat()`, this does not require loading input objects into memory, making it suitable for large datasets.

## Get started

Include this module in your Nextflow pipeline:

```nextflow
include { ANNDATA_CONCATONDISK } from 'cellgeni/anndata/concatondisk'
```

### Inputs

- `tuple val(meta), path(h5ad)`
  - `meta`: sample metadata map (expects an `id` key; used for tagging and default output prefixing)
  - `h5ad`: one or more input AnnData objects in `.h5ad` format
- `val axis`: axis to concatenate along — `obs` or `var`

### Outputs

- `h5ad`: `tuple val(meta), path("*.h5ad")` (concatenated AnnData object written as `combined.h5ad`)
- `versions`: `path("versions.yml")` (tool/package versions captured at runtime)

### Parameters

This module supports passing additional arguments to `concatondisk.py` via `task.ext.args`.

When running the module directly with `nextflow module run`, set these at the command line using Nextflow "process options":

- `-process.ext.args='<CONCATONDISK_ARGS>'`
- `-process.ext.prefix='<SAMPLE_PREFIX>'` (optional; not currently used in output naming)

#### Additional arguments

These are the supported arguments you can include in `ext.args`:

- `--join` (optional, default `inner`): how to align values when concatenating. Choices: `inner`, `outer`.
- `--merge` (optional): how to select elements not aligned to the concatenation axis. Choices: `same`, `unique`, `first`, `only`.
- `--uns-merge` (optional): how to select `.uns` elements. Choices: `same`, `unique`, `first`, `only`.
- `--label` (optional): obs/var column name in which to store batch labels.
- `--keys` (optional): names for each input object, used for the label column or index. Must match the number of input files.
- `--index-unique` (optional): delimiter to make the index unique: `{orig_idx}{delimiter}{key}`.
- `--fill-value` (optional): fill value for introduced indices when `--join=outer`.
- `--max-loaded-elems` (optional, default `100000000`): maximum number of sparse elements to load in memory at once.
- `--pairwise` (optional flag): include pairwise elements along the concatenated dimension.

Notes:

- `--output` and the positional input paths are handled by the module wrapper and do not need to be provided in `ext.args`.
- `--axis` is provided as a dedicated Nextflow input, not via `ext.args`.

#### Full `nextflow module run` example

```bash
nextflow module run cellgeni/anndata/concatondisk \
  --meta.id combined \
  --h5ad "/path/to/sample1.h5ad /path/to/sample2.h5ad /path/to/sample3.h5ad" \
  --axis obs \
  -process.ext.args='--join outer --merge same --label batch --keys s1 s2 s3'
```

## Dependencies

This module runs inside the container `community.wave.seqera.io/library/pip_anndata:61345258b0b4dfd2`.

## License

MIT
