FROM ubuntu:22.04

RUN apt update
RUN apt install -y openssl python3-lz4 python3-protobuf git 

RUN git clone --recursive https://github.com/chenxiaolong/avbroot.git

COPY run.sh run.sh
COPY init.sh init.sh

WORKDIR /
ENTRYPOINT ["/run.sh"]
