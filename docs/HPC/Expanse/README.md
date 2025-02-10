# Install nextflow on Expanse

```bash
module purge
module load slurm
module load gpu/0.17.3b
module load gcc/10.2.0/i62tgso
module load  openjdk/11.0.12_7/xkfgsx7
module load singularitypro/3.11

cd ~
curl -s https://get.nextflow.io | bash
```



# Prepare container image for SDSC Expanse

```bash

EXPANSEPROJECT='YOUR_PROJECT_NAME_ON_EXPANSE'
USERNAME=$USER

cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME
mkdir -p /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/singularity_images



alias srun-shared="srun --account=${EXPANSEPROJECT} --partition=shared --nodes=1 --ntasks-per-node=1 --cpus-per-task=4 --mem=16G --time=00:30:00 --pty --wait=0 /bin/bash"


# enter into compute node
srun-shared


cd /scratch/$USER/job_$SLURM_JOB_ID
mkdir -p /scratch/$USER/job_$SLURM_JOB_ID/cache
export SINGULARITY_CACHEDIR="/scratch/$USER/job_$SLURM_JOB_ID/cache"


EXPANSEPROJECT='YOUR_PROJECT_NAME_ON_EXPANSE'
USERNAME=$USER

cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/singularity_images


module load singularitypro/3.11
singularity pull docker://docker.io/hgrabski/quick:latest


```




# How to run the pipeline as an example (interactive mode)

```bash
# create new tmux session to launch in interactive mode
tmux new-session -s quickflow

EXPANSEPROJECT='YOUR_PROJECT_NAME_ON_EXPANSE'
USERNAME=$USER
YOUREMAIL="YOUR_EMAIL_FOR_NOTIFICATION"

cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME
mkdir -p /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/singularity_images




git clone -b dev https://github.com/hovo1990/nf-core-quickflow.git


mkdir -p quickflow-test-run
cp  -R nf-core-quickflow/docs/HPC/Expanse/ quickflow-test-run/

cd quickflow-test-run/Expanse
#-- * Prepare project NAME


sed -i "s|<<EXPANSEPROJECT>>|${EXPANSEPROJECT}|g" expanse.sb
sed -i "s|<<USERNAME>>|${USERNAME}|g" expanse.sb
sed -i "s|<<YOUREMAIL>>|${YOUREMAIL}|g" expanse.sb

sed -i "s|<<EXPANSEPROJECT>>|${EXPANSEPROJECT}|g" config.yml
sed -i "s|<<USERNAME>>|${USERNAME}|g" config.yml






export NXF_SINGULARITY_CACHEDIR="/expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/singularity_images"
export NXF_APPTAINER_CACHEDIR="/expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/singularity_images"
# run workflow
bash expanse.sb


# to detach

# to reconnect session
tmux attach -t quickflow


# kill tmux session
tmux kill-session  -t quickflow

# -- * The output files will be located at nf-core-quickflow-testout folder accoring to config.yml

```

# Run controller separately

```bash
sbatch expanse.sb
```
