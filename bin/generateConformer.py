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

from openbabel import openbabel, pybel

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
    help="Output generated conformer to xyz file",
    callback=validate_xyz,
    required=True,
)
def start_program(id, name,smiles, output):
    test = 1

    logger.info(" Info>  id {}".format(input))
    logger.info(" Info>  smiles {}".format(smiles))
    logger.info(" Info>  name {}".format(name))
    logger.info(" Info>  output file {}".format(output))
    try:
        #-- * Create an OBMol (Open Babel molecule) from the SMILES string
        obConversion = openbabel.OBConversion()
        obConversion.SetInAndOutFormats("smi", "xyz")

        mol = openbabel.OBMol()
        obConversion.ReadString(mol, smiles)

        #-- * Add hydrogen atoms and optimize the 3D geometry
        mol.AddHydrogens()
        obConversion.SetOutFormat("xyz")  # Set the output format
        pybel.Molecule(mol).make3D()  # Use pybel's make3D function to optimize

        #-- * Export the molecule to a file
        output_filename = output
        obConversion.WriteFile(mol, output_filename)
        exit(0)
    except Exception as e:
        logger.warning(" Error> Unable to save xyz file {}".format(e))
        exit(1)


if __name__ == "__main__":
    start_program()
