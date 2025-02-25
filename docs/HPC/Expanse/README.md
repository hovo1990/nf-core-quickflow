# Step-by-Step Guide: Install and Run Nextflow on SDSC Expanse

This guide walks you through installing Nextflow, preparing a container image, and running a pipeline on SDSC Expanse.

## Prerequisites
- Access to the **SDSC Expanse** system
- A valid **Expanse project account**
- Basic familiarity with **Linux commands**, **SLURM**, **git**
- **Tmux** for managing interactive sessions (optional but recommended)

## 1. Install Nextflow on Expanse

#### Step 1: Load Required Modules
Purge existing modules and load the required ones:
```bash
module purge
module load slurm
module load gpu/0.17.3b
module load gcc/10.2.0/i62tgso
module load openjdk/11.0.12_7/xkfgsx7
module load singularitypro/3.11
```

### Step 2: Download and Install Nextflow

```bash
cd ~
curl -s https://get.nextflow.io | bash
export NEXTFLOW=$(pwd)/nextflow
export PATH=$NEXTFLOW:$PATH
```


## 2. Prepare a Singularity Container Image

### Step 1: Define Your Project Variables

Set up your project name and username:
```bash
EXPANSEPROJECT='YOUR_PROJECT_NAME_ON_EXPANSE'
USERNAME=$USER
```

### Step 2: Create a Directory for Singularity Images

```
cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME
mkdir -p singularity_images
```

### Step 3: Start an Interactive Compute Node Session
Create an alias for an interactive job:


```
alias srun-debug="srun --account=${EXPANSEPROJECT} --partition=debug --nodes=1 --ntasks-per-node=1 --cpus-per-task=4 --mem=16G --time=00:20:00 --pty --wait=0 /bin/bash"
```

Run the command to enter the compute node:
```
srun-debug
```

### Step 4: Set Up Cache Directory from inside the debug node

```
cd /scratch/$USER/job_$SLURM_JOB_ID
mkdir -p cache
export SINGULARITY_CACHEDIR="/scratch/$USER/job_$SLURM_JOB_ID/cache"
```

### Step 5: Pull the Container Image

```
module load singularitypro/3.11

cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/singularity_images

singularity pull docker://docker.io/hgrabski/quick:latest
```

after that exit:
```
exit
```


## 3. Run the Nextflow Pipeline


### Step 1: Start a Tmux Session

To avoid losing progress in case of connection issues, create a tmux session:


```
tmux new-session -s quickflow
```


To reconnect later:
```
tmux attach -t quickflow
```

To terminate the session:
```
tmux kill-session -t quickflow
```

Set up your project name, username and email,so nextflow will send a notification:
```bash
export EXPANSEPROJECT='YOUR_PROJECT_NAME_ON_EXPANSE'
export USERNAME=$USER
export YOUREMAIL="YOUR_EMAIL_FOR_NOTIFICATION"
```


### Step 2: Load Required Modules Again

```
module purge
module load slurm
module load gpu/0.17.3b
module load gcc/10.2.0/i62tgso
module load openjdk/11.0.12_7/xkfgsx7
module load singularitypro/3.11
```

### Step 3: Clone the Pipeline Repository

```
cd /expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME
git clone -b dev https://github.com/hovo1990/nf-core-quickflow.git
```




### 3.1 Export nf-core-quickflow to environment path


```bash
export MAINPATH=/expanse/lustre/projects/$EXPANSEPROJECT/$USERNAME/
export SINGIMAGES=$MAINPATH/singularity_images
export QUICKFLOW=$MAINPATH/nf-core-quickflow
export PATH=$QUICKFLOW:$PATH
```



### Step 4: Prepare Configuration Files

Create a test run directory and copy the example configuration:
```
mkdir -p quickflow-test-run
cp -R nf-core-quickflow/docs/HPC/Expanse/ quickflow-test-run/
cd quickflow-test-run/Expanse
```

Modify the configuration files with your project details:

```
sed -i "s|<<SINGIMAGES>>|${SINGIMAGES}|g" config.yml

```


### Step 5: Run the Workflow
```bash
bash expanse.sb
```

## 4. Run the Pipeline in Batch Mode

To submit the job in batch mode instead of interactive mode:

```bash
sbatch expanse.sb
```
