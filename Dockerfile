FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV TZ=Asia/Singapore
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    bzip2 \
    libx11-6 \
    libsndfile1 \
    build-essential \
    sox wget ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# Set up the Conda environment
ENV HOME=/home/user
RUN mkdir /home/user && chmod 777 /home/user
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH=/home/user/miniconda/bin:$PATH
COPY environment.yml /home/user/environment.yml
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda env update -n base -f /home/user/environment.yml \
 && rm /home/user/environment.yml \
 && conda clean -ya

ADD requirements.txt .
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir -r requirements.txt

COPY ./extensions/cauchy ./cauchy
RUN cd cauchy && python setup.py install

WORKDIR /s4