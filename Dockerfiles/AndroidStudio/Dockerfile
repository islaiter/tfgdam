FROM debian

RUN apt-get update && apt-get install --no-install-recommends -y \
  gcc git openssh-client less curl ca-certificates zip unzip \
  libxtst-dev libxext-dev libxrender-dev libfreetype6-dev \
  libfontconfig1 libgtk2.0-0 libxslt1.1 libxxf86vm1 \
  lib32stdc++6 libmagic1 libpulse0 lib32z1 libncurses5 \
  libglu1-mesa libgl1-mesa-dri mesa-utils libpci3 pciutils usbutils file \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -ms /bin/bash developer \
# required for the developer user to access /dev/kvm
  && adduser developer root

ARG studio_source=https://dl.google.com/dl/android/studio/ide-zips/2021.1.1.22/android-studio-2021.1.1.22-linux.tar.gz
ARG studio_local_dir=AndroidStudio2021.1.1.22

WORKDIR /opt/android-studio

RUN curl -fsSL $studio_source -o /opt/android-studio/installer.tgz \
  && tar --strip-components=1 -xzf installer.tgz \
  && rm installer.tgz

RUN curl -s https://get.sdkman.io | bash \
  && bash -c "source /root/.sdkman/bin/sdkman-init.sh && sdk install kotlin"

#USER developer
#ENV HOME   /home/developer
#ENV SHELL  /bin/bash
ENV PATH   /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/root/Android/Sdk/platform-tools:/opt/android-studio/jre/bin
#ENV JAVA_HOME  /opt/android-studio/jre

#RUN mkdir -p /home/developer/Android/Sdk \
#  && mkdir -p /home/developer/.AndroidStudio \
#  && ln -sf /home/developer/.AndroidStudio /home/developer/$studio_local_dir

CMD [ "/opt/android-studio/bin/studio.sh" ]
