FROM ubuntu:16.04 as dcsscabuilder
# not working, possibly due to compiling dcssca on older ubuntu, But if I dont do that it just throws compilation errors on newer ubuntu versions 
ENV HOME /root
ENV LC_ALL C.UTF-8

RUN apt-get update && \
    apt-get -y install build-essential git libncursesw5-dev bison flex liblua5.1-0-dev \
  libsqlite3-dev libz-dev pkg-config libsdl2-image-dev libsdl2-mixer-dev    \
  libsdl2-dev libfreetype6-dev libpng-dev ttf-dejavu-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt update
RUN apt-get -y install python-yaml

WORKDIR /root
RUN git clone https://github.com/jeremygurr/dcssca.git
WORKDIR /root/dcssca
RUN git config --global url."https://github".insteadOf git://github
RUN git submodule update --init

RUN cd ~/dcssca/crawl-ref/source && make 


FROM alpine:latest as builder

RUN apk add --no-cache make gcc g++ perl git python3 py3-yaml libpng-dev \
    libexecinfo-dev ncurses-dev

WORKDIR /root
RUN git clone https://github.com/crawl/crawl.git
WORKDIR /root/crawl
RUN git config --global url."https://github".insteadOf git://github
RUN git submodule update --init

RUN cd ~/crawl/crawl-ref/source && \
    make -j4 WEBTILES=y EXTRA_LIBS=-lexecinfo

WORKDIR /dcssca
COPY --from=dcsscabuilder /root/dcssca/crawl-ref/source/ /dcssca/
COPY --from=dcsscabuilder /root/dcssca/crawl-ref/settings/ /settings/
COPY --from=dcsscabuilder /root/dcssca/crawl-ref/docs/ /docs/


FROM python:3-alpine

WORKDIR /crawl
COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/source/ /crawl/
COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/settings/ /settings/
COPY --chown=docker:docker --from=builder /root/crawl/crawl-ref/docs/ /docs/
WORKDIR /dcssca
COPY --chown=docker:docker --from=dcsscabuilder /root/dcssca/crawl-ref/source/ /crawl/dcssca/
#COPY --from=dcsscabuilder /root/dcssca/crawl-ref/settings/ /settings/
#COPY --from=dcsscabuilder /root/dcssca/crawl-ref/docs/ /docs/

RUN ln -s /data/ca-rcs rcs
RUN ln -s /data/ca-saves saves
RUN rm /crawl/webserver/config.py
COPY ./config.py /crawl/webserver/config.py
WORKDIR /crawl
RUN apk add --no-cache gcc musl-dev libexecinfo
RUN pip install -r /crawl/webserver/requirements/dev.py3.txt
RUN echo 'password_db = "/data/passwd.db3"' >> /crawl/webserver/config.py
RUN echo 'settings_db = "/data/settings.db3"' >> /crawl/webserver/config.py
RUN ln -s /data/rcs rcs
RUN ln -s /data/saves saves

EXPOSE 8080

USER root
CMD ["sh", "-c", "mkdir -p /data/saves; mkdir -p /data/rcs; mkdir -p /dcssca/data/ca-saves; mkdir -p /dcssca/data/ca-rcs; exec python webserver/server.py"]
