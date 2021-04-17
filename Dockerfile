FROM ubuntu:20.04 AS base
LABEL maintainer=matmaul

ENV ENET_VERSION=1.3.17
ENV STK_VERSION=1.1

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install --no-install-recommends -y build-essential \
        zlib1g-dev \
        libssl-dev \
        sqlite3 \
        curl && \
    apt clean

FROM base AS builder

RUN apt install -y gcc g++ cmake make libcurl4-openssl-dev libssl-dev zlib1g-dev libsqlite3-dev git subversion pkg-config

RUN curl -O http://enet.bespin.org/download/enet-${ENET_VERSION}.tar.gz
RUN tar xf enet-${ENET_VERSION}.tar.gz
RUN cd enet-${ENET_VERSION} && \
    ./configure && \
    make -j$(nproc) && \
    make install

RUN git clone -b ${STK_VERSION} --depth 1 https://github.com/supertuxkart/stk-code.git

# Builds should be reproducible. Therefore using the versioned assets
#RUN svn co https://svn.code.sf.net/p/supertuxkart/code/stk-assets stk-assets
RUN svn checkout https://svn.code.sf.net/p/supertuxkart/code/stk-assets-release/${VERSION}/ stk-assets

RUN mkdir build && \
    cd build && \
    cmake ../stk-code -DSERVER_ONLY=ON && \
    make -j$(nproc) && \
    make install

FROM base

COPY --from=builder /usr/local /usr/local

EXPOSE 2757
EXPOSE 2759
ENTRYPOINT ["/usr/local/bin/supertuxkart"]
