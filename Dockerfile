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
    make -j4 WEBTILES=y CC=gcc-6 CXX=g++-6


WORKDIR /root/crawl
RUN cd ~/crawl/crawl-ref/source && \
    make -j4 WEBTILES=y USE_DGAMELAUNCH=y

WORKDIR /root
RUN git clone https://github.com/Rytisgit/dcssca.git
WORKDIR /root/dcssca
RUN git config --global url."https://github".insteadOf git://github
RUN git submodule update --init
#RUN export PATH=/root/gcc-5.4.0/bin:${PATH} export LD_LIBRARY_PATH=/root/gcc-5.4.0/lib:${LD_LIBRARY_PATH}
RUN cd ~/dcssca/crawl-ref/source && make WEBTILES=y CC=gcc-6 CXX=g++-6

# WORKDIR /crawl
# COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/source/ /crawl/
# COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/settings/ /settings/
# COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/docs/ /docs/
# WORKDIR /dcssca
# COPY --chown=docker:docker --from=builder /root/dcssca/crawl-ref/source/ /crawl/dcssca/
# COPY --chown=docker:docker --from=builder /root/crawl-old/crawl-ref/source/ /crawl/crawl-old/

#RUN ln -s /data/ca-rcs rcs
#RUN ln -s /data/ca-saves saves
# WORKDIR /
# RUN ln -s /root/crawl/crawl-ref/source/ crawln
# WORKDIR /crawln
# RUN ln -s /root/dcssca/crawl-ref/source/ dcssca
# RUN ln -s /root/crawl-old/crawl-ref/source/ crawl-old

# WORKDIR /crawln/

# RUN ln -s /usr/bin/pip3 /usr/bin/pip
# RUN ln -s /usr/bin/python3 /usr/bin/python

# RUN pip install -r /crawln/webserver/requirements/dev.py3.txt
# RUN echo 'password_db = "/data/passwd.db3"' >> /crawln/dcssca/webserver/config.py
# RUN echo 'settings_db = "/data/settings.db3"' >> /crawln/dcssca/webserver/config.py
# RUN mv ./dcssca/webserver ./dcssca/webserver.bc
# RUN cp -a ./webserver ./dcssca
# RUN cp -a ./dcssca/webserver.bc/game_data ./dcssca/webserver
# EXPOSE 8080
# #COPY --chown=docker:docker --from=dcsscabuilder /usr/lib/x86_64-linux-gnu/ /crawl/dcssca/lib/
# RUN rm /crawln/dcssca/webserver/config.py
# COPY ./config.py /crawln/dcssca/webserver/config.py
# WORKDIR /crawln/dcssca
# ENV LC_ALL C.UTF-8
# USER root
# # CMD ["sh", "-c", "LANG=en_US.UTF-8; mkdir -p ./data/saves; mkdir -p ./data/rcs; mkdir -p ./ca-saves; mkdir -p ./ca-rcs; exec python webserver/server.py"]

# FROM ubuntu:18.04
# ENV LC_ALL C.UTF-8
# ENV APP_DEPS="bzip2 liblua5.1-0-dev python3-minimal python3-pip python3-yaml \
#      ncurses-term locales-all sqlite3 libpcre3 locales \
#     lsof sudo libbot-basicbot-perl" \
#   BUILD_DEPS="autoconf gcc-6 g++-6 bison wget build-essential flex git libncursesw5-dev \
#     libsqlite3-dev libz-dev pkg-config binutils-gold libsdl2-image-dev libsdl2-mixer-dev \
#     libsdl2-dev libfreetype6-dev libpng-dev ttf-dejavu-core advancecomp pngcrush" \
#   DEBIAN_FRONTEND=noninteractive

# # Install packages for the build
# RUN apt-get update && \
#   apt-get upgrade -y && \
#   apt-get install -y ${APP_DEPS} && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  
#   COPY --chown=docker:docker --from=builder /root/dcssca/crawl-ref/source/ /crawl/dcssca/