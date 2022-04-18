FROM adoptopenjdk/openjdk8

ARG IDEA_VERSION=2021.3.3
ARG IDEA_BUILD=213.7172.25

RUN  \
  apt-get update && apt-get install --no-install-recommends -y \
  gcc git openssh-client less \
  libxtst-dev libxext-dev libxrender-dev libfreetype6-dev \
  libfontconfig1 libgtk2.0-0 libxslt1.1 libxxf86vm1 \
  && apt-get upgrade -y \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -ms /bin/bash $(whoami)

ARG idea_source=https://download-cdn.jetbrains.com/idea/ideaIC-${IDEA_BUILD}.tar.gz
ARG idea_local_dir=.IdeaIC${IDEA_VERSION}

WORKDIR /opt/idea

RUN curl -fsSL $idea_source -o /opt/idea/installer.tgz \
  && tar --strip-components=1 -xzf installer.tgz \
  && rm installer.tgz

USER $(whoami)
ENV HOME /home/$(whoami)

RUN mkdir /home/$(whoami)/.Idea \
  && ln -sf /home/$(whoami)/.Idea /home/$(whoami)/$idea_local_dir

CMD [ "/opt/idea/bin/idea.sh" ]
