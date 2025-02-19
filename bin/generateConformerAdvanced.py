"""
Author: Hovakim Grabski
Purpose: Generates conformers from a csv input
Date: 02-18-2025

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


import shutil
import pandas as pd
import os
import hashlib
from tqdm.auto import tqdm
from tqdm.contrib import tzip

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

def validate_csv(ctx, param, value):
    logger.info(" Info> validate_csv is ", value)
    if not value.lower().endswith(".csv"):
        raise click.BadParameter("File must have a .csv extension")
    return value







def get_hashed_path(base_dir, filename, levels=2, width=2):
    """Generate a hashed directory path for a given filename.

    Args:
        base_dir (str): Root directory for storage.
        filename (str): Name of the file.
        levels (int): Number of directory levels.
        width (int): Characters per level from hash.

    Returns:
        str: Full directory path.
    """
    file_hash = hashlib.md5(filename.encode()).hexdigest()  # Generate a hash
    subdirs = [file_hash[i * width:(i + 1) * width] for i in range(levels)]
    return os.path.join(base_dir, *subdirs)



def generate_conformer(smiles,output, output_local):
    '''
        Generate conformer using Pybel
    '''
    try:

        # -- * Check if file already exists
        if os.path.exists(output):
            logger.debug(f"File already exists: {output}, simply copying")
            shutil.copy2(output, output_local)
        else:
            # -- * Create an OBMol (Open Babel molecule) from the SMILES string
            obConversion = openbabel.OBConversion()
            obConversion.SetInAndOutFormats("smi", "xyz")

            mol = openbabel.OBMol()
            obConversion.ReadString(mol, smiles)

            # -- * Add hydrogen atoms and optimize the 3D geometry
            mol.AddHydrogens()
            obConversion.SetOutFormat("xyz")  # Set the output format
            pybel.Molecule(mol).make3D()  # Use pybel's make3D function to optimize

            # -- * Export the molecule to a file
            logger.debug(f"File does not exist, writing from scratch")
            output_filename = output
            obConversion.WriteFile(mol, output_filename)
            obConversion.WriteFile(mol, output_local)
    except Exception as e:
        logger.warning(" Error> Unable to save xyz file {}".format(e))
        exit(1)


@click.command()
@click.option(
    "--input",
    help="csv input of the smiles",
    type=click.Path(exists=True),
    required=True,
    callback=validate_csv,
)
@click.option(
    "--cachedir",
    help="custom cache dir to store conformers",
    type=str,
    required=True
)
def start_program(input,cachedir):
    test = 1

    logger.info(" Info>  input {}".format(input))

    logger.info(" Info>  cachedir{}".format(cachedir))


    try:
        df = pd.read_csv(input)
        # print(df)


        for index, row in tqdm(df.iterrows(), total=df.shape[0]):
            # print(row)

            curr_id = row['ID']
            curr_name = row['NAME']
            curr_smiles = row['SMILES']
            curr_filename = f'{curr_name}_{curr_id}.xyz'

            # -- * Get hashed  dir path
            dir_path = get_hashed_path(cachedir, curr_filename )
            # print(dir_path)

            # -- * Create directory
            os.makedirs(dir_path, exist_ok=True)  # Ensure directory exists
            file_path = os.path.join(dir_path, curr_filename)
            print(file_path)

            dest_path = os.path.join(os.getcwd(), curr_filename)

            # -- * Write molecule
            generate_conformer(curr_smiles,file_path, dest_path)

        logger.info(" Info> There were no errors")
        exit(0)
    except Exception as e:
        logger.warning(" Error> Processing the files {}".format(e))
        exit(1)


    # -- * Check if cache directory available or not


    # -- ? Output should look with following format
    # --output="${name}_${id}.xyz"






if __name__ == "__main__":
    start_program()
