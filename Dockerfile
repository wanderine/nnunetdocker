
# Start from CentOS 7
FROM centos:7.6.1810

# Set the shell to bash
SHELL ["/bin/bash", "-c"]

# Install needed packages
RUN yum -y install wget
RUN yum -y install git
RUN yum -y install unzip

# Copy nnUNet environment file
COPY nnUNet-cpu.yaml /home

# Install Anaconda
RUN cd /home && \
  wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh && \
  chmod +x Anaconda3-2019.07-Linux-x86_64.sh && \
  ./Anaconda3-2019.07-Linux-x86_64.sh -b -p ~/anaconda && \
  rm Anaconda3-2019.07-Linux-x86_64.sh

# Add Anaconda to path
ENV PATH=/root/anaconda/bin:$PATH

# Create nnUNet conda environment
RUN cd /home && \
conda env create -f nnUNet-cpu.yaml

# Add nnUNEt environment to path
ENV PATH=/root/anaconda/envs/nnUNet-cpu/bin:$PATH

# Clone and install nnUNet
RUN mkdir /home/nnUNet && \
  cd /home/nnUNet && \
  git clone https://github.com/MIC-DKFZ/nnUNet.git . && \
  pip install -e .
# RUN mkdir /home/nnUNet
# COPY nnUNet /home/nnUNet
# RUN pip install -e /home/nnUNet

# Download trained model
RUN cd /home && \
  wget https://www.dropbox.com/s/kf2wxrj6zl1oy71/results.zip 
RUN mkdir -p /home/nnUNet/data
RUN unzip /home/results.zip -d /home/nnUNet/data

# Set environmental variables for nnUNet
# ENV nnUNet_results=/home/nnUNet/data/results
ENV RESULTS_FOLDER=/home/nnUNet/data/results

# Create folders for input and output data
RUN mkdir /{in,out}

# Copy script for running segmentation
COPY pipeline.sh /home
RUN chmod +x /home/pipeline.sh

ENTRYPOINT ["/home/pipeline.sh"]
