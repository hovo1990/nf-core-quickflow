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

# How to run the pipeline

```bash
EXPANSEPROJECT='YOUR_PROJECT_NAME_ON_EXPANSE'
USERNAME=$USER

cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME

git clone -b dev https://github.com/hovo1990/nf-core-quickflow.git
cd nf-core-quickflow/docs/HPC/Expanse

#-- * Prepare project NAME


sed -i "s|<<EXPANSEPROJECT>>|${EXPANSEPROJECT}|g" expanse.sb
sed -i "s|<<USERNAME>>|${USERNAME}|g" config.yml


sbatch expanse.sb

```
