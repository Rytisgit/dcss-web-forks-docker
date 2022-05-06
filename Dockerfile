# FROM ubuntu:16.04 AS dcsscabuilder
# # not working, possibly due to compiling dcssca on older ubuntu, But if I dont do that it just throws compilation errors on newer ubuntu versions 
# ENV HOME /root


# RUN apt-get update && \
#     apt-get -y install build-essential git libncursesw5-dev bison flex liblua5.1-0-dev \
#   libsqlite3-dev libz-dev pkg-config libsdl2-image-dev libsdl2-mixer-dev    \
#   libsdl2-dev libfreetype6-dev libpng-dev ttf-dejavu-core && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN apt update
# RUN apt-get -y install python-yaml

# WORKDIR /root
# RUN git clone https://github.com/jeremygurr/dcssca.git
# WORKDIR /root/dcssca
# RUN git config --global url."https://github".insteadOf git://github
# RUN git submodule update --init

# RUN cd ~/dcssca/crawl-ref/source && make 


FROM ubuntu:18.04 AS builder
#python-is-python3
ENV CRAWL_REPO="https://github.com/crawl/crawl.git" \
  APP_DEPS="bzip2 liblua5.1-0-dev python3-minimal python3-pip python3-yaml \
     ncurses-term locales-all sqlite3 libpcre3 locales \
    lsof sudo libbot-basicbot-perl" \
  BUILD_DEPS="autoconf gcc-6 g++-6 bison wget build-essential flex git libncursesw5-dev \
    libsqlite3-dev libz-dev pkg-config binutils-gold libsdl2-image-dev libsdl2-mixer-dev \
    libsdl2-dev libfreetype6-dev libpng-dev ttf-dejavu-core advancecomp pngcrush" \
  DEBIAN_FRONTEND=noninteractive

# Install packages for the build
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y ${BUILD_DEPS} ${APP_DEPS}

WORKDIR /root
RUN git clone ${CRAWL_REPO}
WORKDIR /root/crawl
RUN git config --global url."https://github".insteadOf git://github
RUN git submodule update --init

WORKDIR /root/
RUN cp -r ./crawl ./crawl-old
WORKDIR /root/crawl-old
RUN git checkout 0.19.6
RUN cd ~/crawl-old/crawl-ref/source && \
    make -j4 WEBTILES=y USE_DGAMELAUNCH=y CC=gcc-6 CXX=g++-6


WORKDIR /root/crawl
RUN cd ~/crawl/crawl-ref/source && \
    make -j4 WEBTILES=y USE_DGAMELAUNCH=y

# # RUN dpkg --add-architecture i386
# # RUN apt update
# # RUN apt -y upgrade
# # RUN apt -y install make wget git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex bison gettext texinfo ncurses-dev autoconf rsync
# # RUN apt-get -y install gcc-multilib libstdc++6:i386
# # RUN wget https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.bz2 --no-check-certificate
# # RUN tar xf gcc-5.4.0.tar.bz2
# # WORKDIR /root/gcc-5.4.0
# # RUN ./contrib/download_prerequisites
# # WORKDIR /root
# # RUN sed -i -e 's/__attribute__/\/\/__attribute__/g' gcc-5.4.0/gcc/cp/cfns.h
# # RUN sed -i 's/struct ucontext/ucontext_t/g' gcc-5.4.0/libgcc/config/i386/linux-unwind.h
# # RUN mkdir xgcc-5.4.0
# # WORKDIR /root/xgcc-5.4.0
# # RUN $PWD/../gcc-5.4.0/configure --enable-languages=c,c++ --prefix=/usr --enable-shared --enable-plugin --program-suffix=-5.4.0
# # RUN export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH && make MAKEINFO="makeinfo --force" -j
# # RUN make install -j

# # WORKDIR /root
# # RUN wget https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz
# # RUN tar -xzvf gcc-5.4.0.tar.gz
# # WORKDIR /root/gcc-5.4.0
# # RUN ./contrib/download_prerequisites
# # WORKDIR /root/gcc-5.4.0/libgcc
# # RUN grep -rli 'struct ucontext' * | xargs -i@ sed -i 's/struct ucontext/ucontext_t/g' @
# # WORKDIR /root
# # RUN mkdir objdir
# # WORKDIR /root/objdir
# # RUN ./../gcc-5.4.0/configure --prefix=$HOME/GCC-5.4.0 --disable-multilib
# # RUN make CC=gcc-7 all-gcc
# # RUN make CC=gcc-7 all-target-libgcc
# # RUN make CC=gcc-7 install-gcc
# # RUN make CC=gcc-7 install-target-libgcc

WORKDIR /root
RUN git clone https://github.com/jeremygurr/dcssca.git
WORKDIR /root/dcssca
RUN git config --global url."https://github".insteadOf git://github
RUN git submodule update --init
#RUN export PATH=/root/gcc-5.4.0/bin:${PATH} export LD_LIBRARY_PATH=/root/gcc-5.4.0/lib:${LD_LIBRARY_PATH}
RUN cd ~/dcssca/crawl-ref/source && make USE_DGAMELAUNCH=y WEBTILES=y CC=gcc-6 CXX=g++-6

# FROM alpine:latest as builder

# RUN apk add --no-cache make gcc g++ perl git python3 py3-yaml libpng-dev \
#     libexecinfo-dev ncurses-dev
# WORKDIR /root
# RUN git clone https://github.com/jeremygurr/dcssca.git
# WORKDIR /root/dcssca
# RUN git config --global url."https://github".insteadOf git://github
# RUN git submodule update --init

# RUN export PATH=/root/gcc-5.4.0/bin:${PATH} export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/root/gcc-5.4.0/lib:${LD_LIBRARY_PATH}
# RUN update-alternatives --install /usr/bin/gcc gcc /root/GCC-5.4.0/bin/gcc 4

# WORKDIR /dcssca
# COPY --from=dcsscabuilder /root/dcssca/crawl-ref/source/ /dcssca/
# COPY --from=dcsscabuilder /root/dcssca/crawl-ref/settings/ /settings/
# COPY --from=dcsscabuilder /root/dcssca/crawl-ref/docs/ /docs/


FROM ubuntu:18.04

WORKDIR /crawl
COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/source/ /crawl/
COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/settings/ /settings/
COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/docs/ /docs/
WORKDIR /dcssca
COPY --chown=docker:docker --from=builder /root/dcssca/crawl-ref/source/ /crawl/dcssca/
COPY --chown=docker:docker --from=builder /root/crawl-old/crawl-ref/source/ /crawl/crawl-old/

#RUN ln -s /data/ca-rcs rcs
#RUN ln -s /data/ca-saves saves

WORKDIR /crawl
ENV APP_DEPS="bzip2 liblua5.1-0-dev python3-minimal python3-pip python3-yaml \
    ncurses-term locales-all sqlite3 libpcre3 locales \
    lsof sudo libbot-basicbot-perl libncursesw5" \
  DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y ${APP_DEPS}
RUN ln -s /usr/bin/pip3 /usr/bin/pip
RUN ln -s /usr/bin/python3 /usr/bin/python  
RUN pip install -r /crawl/webserver/requirements/dev.py3.txt
RUN echo 'password_db = "/data/passwd.db3"' >> /crawl/webserver/config.py
RUN echo 'settings_db = "/data/settings.db3"' >> /crawl/webserver/config.py
# RUN ln -s /data/rcs rcs
# RUN ln -s /data/saves saves

EXPOSE 8080
#COPY --chown=docker:docker --from=dcsscabuilder /usr/lib/x86_64-linux-gnu/ /crawl/dcssca/lib/
RUN rm /crawl/webserver/config.py
COPY ./config.py /crawl/webserver/config.py
ENV LC_ALL C.UTF-8
USER root
CMD ["sh", "-c", "LANG=en_US.UTF-8; mkdir -p ./data/saves; mkdir -p ./data/rcs; mkdir -p ./ca-saves; mkdir -p ./ca-rcs; exec python webserver/server.py"]
