#-- * This is adapted from
#-- * https://github.com/kkrick-sdsu/QUICK/blob/master/Dockerfile
############################
### Base MPI CUDA 12.0.1 ###
############################
FROM nvidia/cuda:12.0.1-devel-ubuntu22.04 AS base-mpi-cuda-12.0.1

LABEL authors="Hovakim Grabski" \
      description="Docker image containing all software requirements for the nf-core/quickflow pipeline"

RUN apt-get update -y \
 && apt-get install -y \
    gfortran \
    cmake \
    g++ \
    git \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev

RUN mkdir /src \
 && mkdir /src/build

WORKDIR /src

#-- * Git clone quick and release candidate
RUN git clone https://github.com/merzlab/QUICK.git
RUN cd QUICK && mkdir build && git checkout $(git tag -l | sort -V | tail -n 1)


WORKDIR /src/QUICK/build

RUN cmake .. -DCOMPILER=GNU -DCMAKE_INSTALL_PREFIX=$(pwd)/../install -DCUDA=TRUE -DMPI=TRUE

RUN make -j4 install

#############################
## Runtime MPI CUDA 12.0.1 ##
#############################

# Runtime image is smaller than the devel/build image
FROM nvidia/cuda:12.0.1-runtime-ubuntu22.04 AS mpi-cuda-12.0.1
LABEL authors="Hovakim Grabski" \
      description="Docker image containing all software requirements for the nf-core/quickflow pipeline"


# Set up environment variables
ENV MAMBA_ROOT_PREFIX="/opt/micromamba/" 
ENV MAMBA="${MAMBA_ROOT_PREFIX}/bin/micromamba"
ENV ENV_NAME="quick" 
ENV LC_ALL="C" 
ENV PATH="/opt/micromamba/envs/quick/bin:${PATH}" 
ENV LC_ALL="C" 
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y \
 && apt-get install -y \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    graphviz \
    curl \
    bzip2 \
    mlocate \
    locate \
    bash \
    gawk \
    sed


#-- * Install mamba
RUN mkdir -p ${MAMBA_ROOT_PREFIX}
WORKDIR ${MAMBA_ROOT_PREFIX}

RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest  | tar -xvj bin/micromamba
# RUN source ${HOME}/.bashrc

RUN $MAMBA create -n $ENV_NAME -c conda-forge --yes \
    'python==3.11' \
    'numba' \
    'click' \
    'tqdm' \
    'loguru' \
    'python-graphviz' \
    'pandas' \
    'matplotlib' \
    'h5py' \
    'Pillow' \
    'ipywidgets' \
    'scikit-image' \
    'scikit-learn' \
    'astropy' \
    'black' \
    'pytables' \
    'xarray' \
    'netcdf4' \
    'mdtraj' \
    'nglview' \
    'rdkit' \
    'openbabel' \
    'polars' \
    'sqlite' \
    'psycopg' \
    'sqlalchemy'  && \
    "${MAMBA}" clean --all -f -y

# Copy the compiled quick runtimes, leaving behind extra build dependencies & reducing image size
COPY --from=base-mpi-cuda-12.0.1 /src /src

WORKDIR /src/QUICK/install

#-- * activate mamba environment
RUN updatedb
# RUN /bin/bash -c "source /opt/micromamba/etc/profile.d/mamba.sh && micromamba activate ${ENV_NAME}"
# RUN echo "source activate ${ENV_NAME}" > ~/.bashrc

# Manually run steps from quick.rc
ENV QUICK_INSTALL /src/QUICK/install
ENV QUICK_BASIS $QUICK_INSTALL/basis
ENV PATH $PATH:$QUICK_INSTALL/bin
