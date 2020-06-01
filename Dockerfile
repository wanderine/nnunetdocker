
# Start from CentOS 7
FROM nvidia/cuda:10.1-base

# Set the shell to bash
SHELL ["/bin/bash", "-c"]

# Install needed packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget
RUN apt-get install -y git
RUN apt-get install -y unzip

# Install Anaconda
RUN cd /home && \
  wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh && \
  chmod +x Anaconda3-2019.07-Linux-x86_64.sh && \
  ./Anaconda3-2019.07-Linux-x86_64.sh -b -p ~/anaconda && \
  rm Anaconda3-2019.07-Linux-x86_64.sh

# Add Anaconda to path
ENV PATH=/root/anaconda/bin:$PATH

# Create nnUNet conda environment
COPY nnUNet.yaml /home
RUN conda env create -f /home/nnUNet.yaml

# Add nnUNEt environment to path
ENV PATH=/root/anaconda/envs/nnUNet/bin:$PATH

# Clone and install nnUNet
RUN mkdir /home/nnUNet && \
  cd /home/nnUNet && \
  git clone https://github.com/MIC-DKFZ/nnUNet.git . && \
  git checkout 335e0cf4119b18af01baea0ce05c0d23154b9973 && \
  pip install -e .

# Download trained model
RUN cd /home && \
  wget https://www.dropbox.com/s/kf2wxrj6zl1oy71/results.zip
RUN mkdir -p /home/nnUNet/data
RUN unzip /home/results.zip -d /home/nnUNet/data

# Set environmental variables for nnUNet
ENV RESULTS_FOLDER=/home/nnUNet/data/results

# Create folders for input and output data
RUN mkdir /{in,out}

# Copy script for running segmentation
COPY pipeline.sh /home
COPY post_process_segmentation.py /home
RUN chmod +x /home/pipeline.sh

ENTRYPOINT ["/home/pipeline.sh"]
