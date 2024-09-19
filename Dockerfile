# Базовый образ
FROM ubuntu:22.04

# Копируем все deb что рядом внутрь контейнера в tmp
COPY setup-full-8.3.25.1394-x86_64.run /tmp/

# Копируем скрипты конфиг лога
COPY docker-entrypoint.sh /

# Загружаем и устанавливаем что надо
RUN apt-get update \
    && apt-get --yes install locales \
    && localedef -f UTF-8 -i ru_RU ru_RU.UTF-8 \
    && locale-gen ru_RU.UTF-8 \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=ru_RU.UTF-8 \
    && export LC_ALL=ru_RU.UTF-8 \
    && apt-get --yes install tzdata && ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && echo "$TZ" > /etc/timezone \
    && apt-get --yes install gosu \
    && apt-get clean \
    && groupadd -r grp1cv8 --gid=999 \
    && useradd -r -g grp1cv8 --uid=999 --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
    && mkdir --parents /home/usr1cv8/srvinfo \
    && mkdir --parents /var/log/1C /home/usr1cv8/.1cv8/1C/1cv8/conf \
    && chown --recursive usr1cv8:grp1cv8 /var/log/1C /home/usr1cv8 \
    && chmod +x /tmp/setup-full-8.3.25.1394-x86_64.run \
    && ./tmp/setup-full-8.3.25.1394-x86_64.run --mode unattended --enable-components server,ws \
    && rm /tmp/setup-full-8.3.25.1394-x86_64.run \
    && chmod +x /docker-entrypoint.sh

COPY logcfg.xml /home/usr1cv8/.1cv8/1C/1cv8/conf

# Говорим что при запуске контейнера запустить это
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

# Говорим что не плохо было бы подключить к контейнеру настройки и логи (чтобы лежали снаружи)
VOLUME /home/usr1cv8
VOLUME /var/log/1C

# Говорим что могут использоваться эти порты
EXPOSE  1540-1541 1545 1550 1560-1591

# Зачем это здесь я не знаю - запуск ragent
CMD ["ragent"]