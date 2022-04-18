FROM debian

ARG PYCHARM_VERSION=2021.3.3
ARG PYCHARM_BUILD=213.7172.26

RUN apt-get update && apt-get install --no-install-recommends -y \
  python python-dev python-setuptools python3-pip \
  python3 python3-dev python3-setuptools python3-pip \
  gcc git openssh-client less curl \
  libxtst-dev libxext-dev libxrender-dev libfreetype6-dev \
  libfontconfig1 libgtk2.0-0 libxslt1.1 libxxf86vm1 \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get upgrade -y \
  && useradd -ms /bin/bash maniana

ARG pycharm_source=https://download-cdn.jetbrains.com/python/pycharm-professional-2021.3.3.tar.gz

ARG pycharm_local_dir=.PyCharmCE${PYCHARM_VERSION}

WORKDIR /opt/pycharm

RUN curl -fsSL $pycharm_source -o /opt/pycharm/installer.tgz \
  && tar --strip-components=1 -xzf installer.tgz \
  && rm installer.tgz

USER maniana
ENV HOME /home/maniana

RUN mkdir /home/maniana/.PyCharm \
  && ln -sf /home/maniana/.PyCharm /home/maniana/$pycharm_local_dir

CMD [ "/opt/pycharm/bin/pycharm.sh" ]
