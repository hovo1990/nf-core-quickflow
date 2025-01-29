"""
Author: Hovakim Grabski
Purpose: Generates Quick settings for the conformer and calculation
Date: 11-29-2024

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





@click.command()
@click.option(
    "--hamiltonian",
    help="hamiltonian for the calculation",
    required=True,
    type=str,
)
@click.option(
    "--dft_method",
    help="dft method",
    required=True,
    type=str
)
@click.option(
    "--basis",
    help="basis",
    required=True,
    type=str,
)

@click.option(
    "--scf_cutoff",
    help="scf_cutoff",
    required=True,
    type=str,
)
@click.option(
    "--scf_denserms",
    help="scf_denserms",
    required=True,
    type=str,
)

@click.option(
    "--charge",
    help="charge",
    required=True,
    type=int,
)
@click.option(
    "--mult",
    help="mult",
    required=True,
    type=int,
)
@click.option(
    "--gradient",
    help="gradient",
    required=True,
    type=bool
)
@click.option(
    "--dipole",
    help="dipole",
    required=True,
    type=bool
)
@click.option(
    "--optimize",
    help="optimize",
    required=True,
    type=bool
)
@click.option(
    "--export",
    help="export",
    required=True,
    type=str,
)
@click.option(
    "--output",
    help="output",
    required=True,
    type=str,
)
def start_program(hamiltonian,dft_method,basis,
                scf_cutoff,scf_denserms,
                charge,
                mult,
                gradient,
                dipole,
                optimize,
                export,
                output
):
    test = 1

    logger.debug(" Info>  hamiltonian {}".format(hamiltonian))
    logger.debug(" Info>  dft_method {}".format(dft_method))
    logger.debug(" Info>  basis {}".format(basis))
    logger.debug(" Info>  scf_cutoff {}".format(scf_cutoff))
    logger.debug(" Info> scf_denserms {}".format(scf_denserms))
    logger.debug(" Info>  charge {}".format(charge))
    logger.debug(" Info>  mult {}".format(mult))
    logger.debug(" Info>  gradient {}".format(gradient))
    logger.debug(" Info>  dipole {}".format(dipole))
    logger.debug(" Info>  optimize {}".format(optimize))
    logger.debug(" Info>  export {}".format(export))
    try:
        #-- * start creating Quick settings for the compounds
        mainArg = ''
        mainArg += hamiltonian + " "
        if hamiltonian == 'DFT' or hamiltonian =="UDFT":
            mainArg += dft_method + " "

        mainArg += basis + " "
        mainArg += "cutoff=" + scf_cutoff + " "
        mainArg += "denserms=" + scf_denserms + " "

        mainArg += "CHARGE=" + str(charge) + " "
        mainArg += "MULT=" + str(mult) + " "

        if gradient is True:
            mainArg += "GRADIENT" + " "

        if dipole is True:
            mainArg += "DIPOLE" + " "

        if optimize is True:
            mainArg += "OPTIMIZE" + " "

        if export is not None:
            mainArg += "EXPORT=" + str(export) + " "

        logger.debug(" Info>  mainArg ->  {}".format(mainArg))
        # sys.stdout.write(mainArg)
        with open(output, "w") as file:
            file.write(mainArg)
        exit(0)
    except Exception as e:
        logger.warning(" Error> Unable to save xyz file {}".format(e))
        exit(1)


if __name__ == "__main__":
    start_program()
