FROM ubuntu:19.10 AS base

RUN apt update && apt dist-upgrade -y && apt install -y zlib1g libssl1.1 sqlite3 curl && apt clean

FROM base AS builder

RUN apt install -y gcc g++ cmake make libcurl4-openssl-dev libssl-dev zlib1g-dev libsqlite3-dev git subversion pkg-config

RUN curl -O http://enet.bespin.org/download/enet-1.3.14.tar.gz
RUN tar xf enet-1.3.14.tar.gz
RUN cd enet-1.3.14 && ./configure && make -j4 && make install

RUN git clone -b 1.1 --depth 1 https://github.com/supertuxkart/stk-code.git
RUN svn co https://svn.code.sf.net/p/supertuxkart/code/stk-assets stk-assets
#COPY stk-code stk-code
#COPY stk-assets stk-assets

RUN mkdir build && cd build && cmake ../stk-code -DSERVER_ONLY=ON && make -j4 && make install

FROM base

COPY --from=builder /usr/local /usr/local

ENTRYPOINT ["/usr/local/bin/supertuxkart"]
