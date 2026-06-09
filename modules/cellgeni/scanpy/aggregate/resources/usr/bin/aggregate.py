#!/usr/bin/env python3

import argparse
import anndata
import scanpy as sc
import logging


def parse_args():
    parser = argparse.ArgumentParser(
        description="Aggregate an AnnData object using scanpy.get.aggregate"
    )
    parser.add_argument("input", help="Path to input AnnData (.h5ad) file")
    parser.add_argument(
        "--output", required=True, help="Path to output AnnData (.h5ad) file"
    )
    parser.add_argument(
        "--by",
        required=True,
        nargs="+",
        help="Key(s) of the column(s) to group by",
    )
    parser.add_argument(
        "--func",
        required=True,
        nargs="+",
        choices=["count_nonzero", "sum", "median", "mean", "var"],
        help="Aggregation function(s) to apply",
    )
    parser.add_argument(
        "--axis",
        choices=["obs", "var"],
        default=None,
        required=True,
        help="Axis on which to find the group-by column (default: inferred)",
    )
    parser.add_argument(
        "--mask",
        default=None,
        help="Key to a boolean column to use as a mask along the axis",
    )
    parser.add_argument(
        "--dof",
        type=int,
        default=1,
        help="Degrees of freedom for variance calculation (default: 1)",
    )
    parser.add_argument(
        "--layer",
        default=None,
        help="Key of the layer to use for aggregation instead of X",
    )
    parser.add_argument(
        "--obsm",
        default=None,
        help="Key of obsm to use for aggregation instead of X",
    )
    parser.add_argument(
        "--varm",
        default=None,
        help="Key of varm to use for aggregation instead of X",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    adata = anndata.read_h5ad(args.input)

    by = args.by[0] if len(args.by) == 1 else args.by
    func = args.func[0] if len(args.func) == 1 else args.func

    # drop NaN values from the group-by column(s) to avoid errors during aggregation
    for col in args.by:
        if args.axis == "obs":
            na_entries = adata.obs[col].isna()
            if na_entries.any():
                logging.warning(
                    f"Dropping {na_entries.sum()} entries with NaN values in obs['{col}']"
                )
            adata = adata[~adata.obs[col].isna()]
        elif args.axis == "var":
            na_entries = adata.var[col].isna()
            if na_entries.any():
                logging.warning(
                    f"Dropping {na_entries.sum()} entries with NaN values in var['{col}']"
                )
            adata = adata[:, ~adata.var[col].isna()]

    result = sc.get.aggregate(
        adata,
        by=by,
        func=func,
        axis=args.axis,
        mask=args.mask,
        dof=args.dof,
        layer=args.layer,
        obsm=args.obsm,
        varm=args.varm,
    )

    result.write_h5ad(args.output)


if __name__ == "__main__":
    main()
