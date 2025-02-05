# Install nextflow on Expanse

```bash
module purge
module load slurm
module load gpu/0.17.3b
module load gcc/10.2.0/i62tgso
module load  openjdk/11.0.12_7/xkfgsx7

cd ~
curl -s https://get.nextflow.io | bash
```

# How to run the pipeline as an example

```bash
EXPANSEPROJECT='YOUR_PROJECT_NAME_ON_EXPANSE'
USERNAME=$USER


cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME
mkdir -p /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/singularity_images


git clone -b dev https://github.com/hovo1990/nf-core-quickflow.git
cd nf-core-quickflow/docs/HPC/Expanse

#-- * Prepare project NAME


sed -i "s|<<EXPANSEPROJECT>>|${EXPANSEPROJECT}|g" expanse.sb
sed -i "s|<<USERNAME>>|${USERNAME}|g" expanse.sb

sed -i "s|<<EXPANSEPROJECT>>|${EXPANSEPROJECT}|g" config.yml
sed -i "s|<<USERNAME>>|${USERNAME}|g" config.yml


sbatch expanse.sb

# -- * The output files will be located at nf-core-quickflow-testout folder accoring to config.yml

```
