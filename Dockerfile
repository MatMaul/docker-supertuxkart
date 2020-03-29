FROM docker.io/centos:7 AS builder

RUN yum update -y

RUN yum install -y gcc-c++ cmake make openssl-devel libcurl-devel zlib-devel sqlite-devel git svn

RUN curl -O http://enet.bespin.org/download/enet-1.3.14.tar.gz

RUN tar xf enet-1.3.14.tar.gz

RUN cd enet-1.3.14 && ./configure && make -j4 && make install

RUN git clone -b 1.1 --depth 1 https://github.com/supertuxkart/stk-code.git
RUN svn co https://svn.code.sf.net/p/supertuxkart/code/stk-assets stk-assets
#COPY stk-code stk-code
#COPY stk-assets stk-assets

RUN mkdir build

RUN cd build && cmake ../stk-code -DSERVER_ONLY=ON && make -j4 && make install


FROM docker.io/centos:7

RUN yum update -y && yum install -y zlib libcurl openssl sqlite && yum clean all

COPY --from=0 /usr/local /user/local

ENTRYPOINT /usr/local/bin/supertuxkart
