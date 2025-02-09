# Create GPU instance in Jetstream2 on Almalinux 9  base image

## Steps to do

SSH into machine, lets install some modules


```bash
# install apptainer
sudo dnf install apptainer -y

# install openjdk
sudo dnf install java-21-openjdk

# switch to open jdk to jdk 21
sudo alternatives --config java


# install nextflow
curl -s https://get.nextflow.io | bash

# check if it works
~/nextflow -v


```
