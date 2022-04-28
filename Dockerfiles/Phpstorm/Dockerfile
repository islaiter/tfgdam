FROM ubuntu:20.04


RUN apt-get update && apt-get install -y software-properties-common && apt --fix-broken install python-pycurl python-apt -y && add-apt-repository ppa:ondrej/php && apt-get update && \
    apt-get install -y software-properties-common wget git curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update && \
  # php8.1-recode is now include in pcl since php7.4+ php8.1-json
    apt-get install -y --allow-unauthenticated graphviz phpunit nodejs \
        php8.1-cli php8.1-dev php8.1-curl php8.1-gd php8.1-gmp  php8.1-ldap php8.1-mysql php8.1-odbc php8.1-pgsql php8.1-pspell php8.1-readline php8.1-sqlite3 php8.1-tidy php8.1-xml php8.1-xmlrpc php8.1-bcmath php8.1-bz2 php8.1-enchant php8.1-imap php8.1-interbase php8.1-intl php8.1-mbstring php8.1-mcrypt php8.1-soap php8.1-sybase php8.1-xsl php8.1-zip php-memcache php-memcached php-pear \
        openjdk-8-jre libxext-dev libxrender-dev libxtst-dev && \
    pecl install xdebug && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* \
    && apt-get upgrade -y

RUN useradd -m -s /bin/bash developer \
    && mkdir /home/developer/.PhpStorm2022.1 \
    && touch /home/developer/.PhpStorm2022.1/.keep \
    && chown -R developer.developer /home/developer \
    && mkdir /opt/phpstorm
    # \
    #&& wget -O - https://download.jetbrains.com/webide/PhpStorm-2017.1.tar.gz | tar xzf - --strip-components=1 -C "/opt/phpstorm"
    
ARG studio_source=https://download-cdn.jetbrains.com/webide/PhpStorm-2022.1.tar.gz
ARG studio_local_dir=AndroidStudio2022.tar.gz

WORKDIR /opt/phpstorm

RUN curl -fsSL $studio_source -o /opt/phpstorm/installer.tgz \
  && tar --strip-components=1 -xzf installer.tgz \
  && rm installer.tgz

RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin
RUN phpenmod curl gd gmp json ldap mysql odbc pgsql pspell readline recode snmp sqlite3 tidy xml xmlrpc bcmath bz2 enchant imap interbase intl mbstring mcrypt soap sybase xsl zip xdebug memcache memcached
#RUN php5enmod mcrypt curl
RUN wget -c https://phpmd.org/static/latest/phpmd.phar -O /usr/bin/phpmd.phar && chmod +x /usr/bin/phpmd.phar
RUN pear install PHP_CodeSniffer
RUN npm install -g bower

USER developer
VOLUME /home/developer/.PhpStorm2021.1
CMD /opt/phpstorm/bin/phpstorm.sh
