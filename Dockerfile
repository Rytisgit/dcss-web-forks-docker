FROM ubuntu:20.04 AS builder
# not working, possibly due to compiling dcssca on older ubuntu, But if I dont do that it just throws compilation errors on newer ubuntu versions 
ENV HOME /root
ENV LC_ALL C.UTF-8
ENV CRAWL_REPO="https://github.com/crawl/crawl.git" \
  APP_DEPS="bzip2 liblua5.1-0-dev python3-minimal python3-pip python3-yaml \
    python-is-python3 ncurses-term locales-all sqlite3 libpcre3 locales \
    lsof sudo libbot-basicbot-perl" \
  BUILD_DEPS="autoconf bison build-essential flex wget git libncursesw5-dev \
    libsqlite3-dev libz-dev pkg-config binutils-gold libsdl2-image-dev libsdl2-mixer-dev \
    libsdl2-dev libfreetype6-dev libpng-dev ttf-dejavu-core advancecomp pngcrush" \
    BUILD_OLD_DEPS="build-essential git libncursesw5-dev bison flex liblua5.1-0-dev \
  libsqlite3-dev libz-dev pkg-config libsdl2-image-dev libsdl2-mixer-dev    \
  libsdl2-dev libfreetype6-dev libpng-dev ttf-dejavu-core" \
  DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install ${BUILD_DEPS} ${APP_DEPS} ${BUILD_OLD_DEPS} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# RUN apt-get -y install python-yaml

WORKDIR /root

RUN dpkg --add-architecture i386
RUN apt update
RUN apt -y upgrade
RUN apt -y install make wget git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex bison gettext texinfo ncurses-dev autoconf rsync
RUN apt-get -y install gcc-multilib libstdc++6:i386
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.bz2 --no-check-certificate
RUN tar xf gcc-4.8.5.tar.bz2
WORKDIR /root/gcc-4.8.5
RUN ./contrib/download_prerequisites
WORKDIR /root
RUN sed -i -e 's/__attribute__/\/\/__attribute__/g' gcc-4.8.5/gcc/cp/cfns.h
RUN sed -i 's/struct ucontext/ucontext_t/g' gcc-4.8.5/libgcc/config/i386/linux-unwind.h
RUN mkdir xgcc-4.8.5
WORKDIR /root/xgcc-4.8.5
RUN $PWD/../gcc-4.8.5/configure --enable-languages=c,c++ --prefix=/usr --enable-shared --enable-plugin --program-suffix=-4.8.5
# RUN export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH && make MAKEINFO="makeinfo --force" -j
# RUN make install -j

# RUN wget https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz
# RUN tar -xzvf gcc-5.4.0.tar.gz
# WORKDIR /root/gcc-5.4.0
#  RUN ./contrib/download_prerequisites
# WORKDIR /root
# RUN mkdir objdir
# WORKDIR /root/objdir
# RUN ./../gcc-5.4.0/configure --prefix=$HOME/GCC-5.4.0 --disable-multilib
# RUN make all-gcc
# RUN make all-target-libgcc
# RUN make install-gcc
# RUN make install-target-libgcc


# WORKDIR /root
# RUN git clone https://github.com/jeremygurr/dcssca.git
# WORKDIR /root/dcssca
# RUN git config --global url."https://github".insteadOf git://github
# RUN git submodule update --init

# RUN export PATH=/root/gcc-5.4.0/bin:${PATH} export LD_LIBRARY_PATH=/root/gcc-5.4.0/lib:${LD_LIBRARY_PATH}
# RUN update-alternatives --install /usr/bin/gcc gcc /root/GCC-5.4.0/bin/gcc 4


#RUN cd ~/dcssca/crawl-ref/source && make 


# FROM alpine:latest as builder

# RUN apk add --no-cache make gcc g++ perl git python3 py3-yaml libpng-dev \
#     libexecinfo-dev ncurses-dev

# WORKDIR /root
# RUN git clone https://github.com/crawl/crawl.git
# WORKDIR /root/crawl
# RUN git config --global url."https://github".insteadOf git://github
# RUN git submodule update --init

# RUN cd ~/crawl/crawl-ref/source && \
#     make -j4 WEBTILES=y EXTRA_LIBS=-lexecinfo

# WORKDIR /dcssca
# COPY --from=dcsscabuilder /root/dcssca/crawl-ref/source/ /dcssca/
# COPY --from=dcsscabuilder /root/dcssca/crawl-ref/settings/ /settings/
# COPY --from=dcsscabuilder /root/dcssca/crawl-ref/docs/ /docs/


# FROM python:3-alpine

# WORKDIR /crawl
# COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/source/ /crawl/
# COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/settings/ /settings/
# COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/docs/ /docs/
# WORKDIR /dcssca
# COPY --chown=docker:docker --from=dcsscabuilder /root/dcssca/crawl-ref/source/ /crawl/dcssca/
# #COPY --from=dcsscabuilder /root/dcssca/crawl-ref/settings/ /settings/
# #COPY --from=dcsscabuilder /root/dcssca/crawl-ref/docs/ /docs/

# RUN ln -s /data/ca-rcs rcs
# RUN ln -s /data/ca-saves saves
# RUN rm /crawl/webserver/config.py
# COPY ./config.py /crawl/webserver/config.py
# WORKDIR /crawl
# RUN apk add --no-cache gcc musl-dev libexecinfo
# RUN pip install -r /crawl/webserver/requirements/dev.py3.txt
# RUN echo 'password_db = "/data/passwd.db3"' >> /crawl/webserver/config.py
# RUN echo 'settings_db = "/data/settings.db3"' >> /crawl/webserver/config.py
# RUN ln -s /data/rcs rcs
# RUN ln -s /data/saves saves

# EXPOSE 8080

# USER root
# CMD ["sh", "-c", "mkdir -p /data/saves; mkdir -p /data/rcs; mkdir -p /dcssca/data/ca-saves; mkdir -p /dcssca/data/ca-rcs; exec python webserver/server.py"]
