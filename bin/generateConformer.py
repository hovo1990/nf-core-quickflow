"""
Author: Hovakim Grabski
Purpose: Generates a single confomer based on smiles
Date: 11-04-2024

https://openbabel.org/docs/3DStructureGen/SingleConformer.html
Details on some of the trade-offs involved are outlined in ‘Fast, efficient fragment-based coordinate generation for Open Babel’ *J. Cheminf.* (2019) **11**, Art. 49.<https://doi.org/10.1186/s13321-019-0372-5>. If you use the 3D coordinate generation, please cite this paper.

"""

import math
import os
import pathlib
import sys
import time
from itertools import combinations
from loguru import logger

import click
import openbabel

def logger_wraps(*, entry=True, exit=True, level="DEBUG"):
    def wrapper(func):
        name = func.__name__

        @functools.wraps(func)
        def wrapped(*args, **kwargs):
            logger_ = logger.opt(depth=1)
            if entry:
                logger_.log(
                    level, "Entering '{}' (args={}, kwargs={})", name, args, kwargs
                )
            result = func(*args, **kwargs)
            if exit:
                logger_.log(level, "Exiting '{}' (result={})", name, result)
            return result

        return wrapped

    return wrapper


def timeit(func):
    def wrapped(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        logger.debug("Function '{}' executed in {:f} s", func.__name__, end - start)
        return result

    return wrapped


def validate_xyz(ctx, param, value):
    logger.info(" Info> validate_xyz is ", value)
    if not value.lower().endswith(".xyz"):
        raise click.BadParameter("File must have a .xyz extension")
    return value


@click.command()
@click.option(
    "--id",
    help="id of the compound",
    required=True,
)
@click.option(
    "--name",
    help="compound name",
    required=True,
)
@click.option(
    "--smiles",
    help="compound smiles",
    required=True,
)
@click.option(
    "--output",
    help="Output selected table to a bsv file",
    callback=validate_xyz,
    required=True,
)
def start_program(input, output):
    test = 1

    logger.info(" Info>  id {}".format(input))
    logger.info(" Info>  output file {}".format(output))

    # # test = 1

    # csv_df = pd.read_csv(input, header=None)
    # # print(csv_df)

    # try:
    #     full_list = []
    #     for i in csv_df[0]:
    #         # print(i)
    #         temp_df = pd.read_csv(i)
    #         # print(temp_df)
    #         full_list.append(temp_df)

    #     final_df = pd.concat(full_list)
    #     final_df.reset_index(inplace=True, drop=True)

    #     final_df.to_csv(output, index=False)
    #     # print(final_df)
    #     exit(0)
    # except Exception as e:
    #     logger.warning(" Error> Unable to save csv file {}".format(e))
    #     exit(1)


if __name__ == "__main__":
    start_program()
