# docker build -t dleongsh/s4:nvcr-21.06 .
FROM nvcr.io/nvidia/pytorch:21.06-py3

ENV TZ=Asia/Singapore
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install some basic utilities
RUN apt-get update && apt-get install -y \ 
    ca-certificates gcc g++ \
    curl wget git \
    libsndfile1 sox ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE 1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED 1

ADD requirements.txt .
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir --ignore-installed llvmlite==0.38.0 && \
    python3 -m pip install --no-cache-dir torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 torchtext==0.11.0 -f https://download.pytorch.org/whl/torch_stable.html && \
    python3 -m pip install --no-cache-dir -r requirements.txt

# Install cauchy extension
COPY ./extensions/cauchy ./cauchy
RUN cd cauchy && python setup.py install

WORKDIR /s4