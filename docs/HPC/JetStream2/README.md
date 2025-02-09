# Create GPU instance in Jetstream2 on Almalinux 9  base image

## Setup machine for the pipeline

SSH into machine, lets install some modules


```bash
# install apptainer
sudo dnf install -y epel-release
sudo dnf install apptainer apptainer-suid libxslt-devel -y

# install openjdk
sudo dnf install java-21-openjdk

# switch to open jdk to jdk 21
sudo alternatives --config java



# reboot machine
sudo reboot -h now


# install nextflow
curl -s https://get.nextflow.io | bash

# check if it works
~/nextflow -v



# let us test if nvidia gpu inside apptainer is working
mkdir -p ~/singularity_images
cd ~/singularity_images
apptainer pull docker://nvidia/cuda:12.0.1-runtime-ubuntu22.04

# run nvidia-smi using apptainer
apptainer run --nv cuda_12.0.1-runtime-ubuntu22.04.sif nvidia-smi
```

## Run pipeline


```bash
# create new tmux session to launch in interactive mode
tmux new-session -s quickflow

USERNAME=$USER



cd ~

git clone -b dev https://github.com/hovo1990/nf-core-quickflow.git


mkdir -p quickflow-test-run
cp  -R nf-core-quickflow/docs/HPC/JetStream2/ quickflow-test-run/

cd quickflow-test-run/JetStream2
#-- * Prepare project NAME

sed -i "s|<<USERNAME>>|${USERNAME}|g" jtgpu.sb
sed -i "s|<<USERNAME>>|${USERNAME}|g" config.yml

# run workflow
bash jtgpu.sb


# to detach

# to reconnect session
tmux attach -t quickflow


# kill tmux session
tmux kill-session  -t quickflow

# -- * The output files will be located at nf-core-quickflow-testout folder accoring to config.yml

```
