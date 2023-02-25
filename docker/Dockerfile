FROM ubuntu:22.04

ARG EXTRACT
ARG UID
ARG GID
ARG UNAME
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}

RUN apt update
RUN apt install -y openssl python3-lz4 python3-protobuf git 

RUN git clone --recursive https://github.com/chenxiaolong/avbroot.git

COPY run.sh run.sh
COPY init.sh init.sh

WORKDIR /
ENTRYPOINT ["/run.sh"]
