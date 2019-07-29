FROM centos:7.6.1810

#RUN rm /bin/sh 
#RUN ln -s /bin/bash /bin/sh 

RUN yum -y install wget 

RUN yum -y install git

RUN yum -y install unzip

RUN mkdir Downloads 

COPY nnUNet_env.yaml  Downloads

COPY pipeline.sh /home

RUN cd Downloads && \
wget https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh && \
chmod +x Anaconda3-2019.07-Linux-x86_64.sh && \
./Anaconda3-2019.07-Linux-x86_64.sh -b -p ~/anaconda && \
rm Anaconda3-2019.07-Linux-x86_64.sh

RUN export PATH=$PATH:/root/anaconda/bin

RUN cd Downloads && \
~/anaconda/bin/conda env create -f nnUNet_env.yaml

RUN ~/anaconda/bin/activate nnUNet

RUN mkdir repository && \
cd repository && \
git clone https://github.com/MIC-DKFZ/nnUNet.git . && \
/root/anaconda/bin/pip install -e .

RUN chmod +x /home/pipeline.sh

ENTRYPOINT ["/home/pipeline.sh"]






