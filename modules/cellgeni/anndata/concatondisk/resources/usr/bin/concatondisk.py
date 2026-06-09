#!/usr/bin/env python3

import argparse
from pathlib import Path
import anndata


def parse_args():
    parser = argparse.ArgumentParser(
        description="Concatenate AnnData files on disk using anndata.experimental.concat_on_disk"
    )
    parser.add_argument(
        "input",
        nargs="+",
        help="Paths to input AnnData (.h5ad) files",
    )
    parser.add_argument(
        "--output", required=True, help="Path to output AnnData (.h5ad) file"
    )
    parser.add_argument(
        "--max-loaded-elems",
        type=int,
        default=100_000_000,
        help="Maximum number of elements to load in memory when concatenating sparse arrays (default: 100000000)",
    )
    parser.add_argument(
        "--axis",
        choices=["obs", "var"],
        default="obs",
        help="Axis to concatenate along (default: obs)",
    )
    parser.add_argument(
        "--join",
        choices=["inner", "outer"],
        default="inner",
        help="How to align values when concatenating (default: inner)",
    )
    parser.add_argument(
        "--merge",
        choices=["same", "unique", "first", "only"],
        default=None,
        help="How to select elements not aligned to the concatenation axis",
    )
    parser.add_argument(
        "--uns-merge",
        choices=["same", "unique", "first", "only"],
        default=None,
        help="How to select .uns elements (default: None, no elements kept)",
    )
    parser.add_argument(
        "--label",
        default=None,
        help="Column in obs/var to store batch information in",
    )
    parser.add_argument(
        "--keys",
        nargs="+",
        default=None,
        help="Names for each input object (used for label column or index). Must match number of input files.",
    )
    parser.add_argument(
        "--index-unique",
        default=None,
        help="Delimiter to make index unique: '{orig_idx}{delimiter}{key}'. When omitted, original indices are kept.",
    )
    parser.add_argument(
        "--fill-value",
        default=None,
        help="Fill value used when --join=outer for introduced indices",
    )
    parser.add_argument(
        "--pairwise",
        action="store_true",
        default=False,
        help="Include pairwise elements along the concatenated dimension",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    if (
        args.keys is not None
        and len(args.keys) != len(args.input)
        and (args.label is not None or args.index_unique is not None)
    ):
        raise ValueError(
            f"Number of --keys ({len(args.keys)}) must match number of input files ({len(args.input)})"
        )

    inputs = [Path(p) for p in args.input]

    anndata.experimental.concat_on_disk(
        in_files=inputs,
        out_file=args.output,
        max_loaded_elems=args.max_loaded_elems,
        axis=args.axis,
        join=args.join,
        merge=args.merge,
        uns_merge=args.uns_merge,
        label=args.label,
        keys=None,  # handled via in_files mapping when --keys provided
        index_unique=args.index_unique,
        fill_value=args.fill_value,
        pairwise=args.pairwise,
    )


if __name__ == "__main__":
    main()
