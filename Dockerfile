ARG BASE_IMAGE="nvidia/cuda:11.3.1-base-ubuntu20.04"

FROM ${BASE_IMAGE}

LABEL maintainer="Heterogeneous Graph Pretraining Project <zaiqiao.meng@gmail.com>"

WORKDIR /root

# Updating Ubuntu packages
RUN apt-get update && yes|apt-get upgrade
RUN apt-get install -y emacs

# Adding wget and bzip2
RUN apt-get install -y wget bzip2
RUN apt-get install -y gcc python3-dev

# Anaconda installing
RUN wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh
RUN bash Anaconda3-2021.11-Linux-x86_64 -b
RUN rm Anaconda3-2021.11-Linux-x86_64.sh

# Set path to conda
ENV PATH /root/anaconda3/bin:$PATH

# Updating Anaconda packages
RUN conda update conda
# RUN conda update anaconda
# RUN conda update --all

# Install pytorch  pytorch-geometric
RUN conda install pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch
RUN conda install pyg -c pyg

# Configuring access to Jupyter
RUN mkdir /root/notebooks
RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u'sha1:3374f2acd0ecdafc217166e8e27b7cead7682280'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.ip='*'" >> /root/.jupyter/jupyter_notebook_config.py
# jupyter notbook password: root

# clone repo
RUN mkdir /root/ProtTrans
ADD . /root/ProtTrans

RUN cd /root/ProtTrans && pip install --upgrade pip && \
    pip install jupyterlab && \
    pip install flake8==3.7.9 --ignore-installed &&\
    pip install --no-cache-dir -r requirements.txt
RUN cd /root/ProtTrans

# Jupyter listens port: 8888
EXPOSE 8888

CMD ["jupyter", "lab", "--allow-root", "--notebook-dir=/root/beta-recsys", "--ip='*'", "--port=8888", "--no-browser"]
