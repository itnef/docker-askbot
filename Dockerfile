FROM ubuntu:20.04 

LABEL maintainer="N. E. Flick <neflick@itemis.com>"

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y python3-pip libsasl2-dev python3-dev libldap2-dev libssl-dev git libjpeg-dev

VOLUME ["/data"]

# Install askbot
# isn't up to date:
# RUN pip install askbot

RUN pip3 install --upgrade pip

RUN pip3 install uWSGI

# Necessary for the optional LDAP support
RUN pip3 install python-ldap

# we need version 0.11.x  which has been ported to python3:

RUN git clone https://github.com/ASKBOT/askbot-devel

WORKDIR /askbot-devel
RUN git checkout 0.11.x
RUN git status

RUN python3 setup.py build
RUN python3 setup.py install

# Setup askbot (defaults to using sqlite)
RUN python3 `which askbot-setup` -n /app -e 2 -d /data/askbot.db

WORKDIR /

# RUN ls -la /app/askbot_app
# Disable debug mode (see readme on enabling):
# RUN sed -i "s|^DEBUG = True|DEBUG = False|" /app/askbot_app/settings.py

# WORKDIR /app

# Append some stuff to add to python's import path and allow for settings overriding
COPY ./conf/settings-override.py /app/askbot_app/settings-override.py
RUN cat /app/askbot_app/settings-override.py >> /app/askbot_app/settings.py
RUN rm /app/askbot_app/settings-override.py

# # Copy over some runtime stuff
COPY ./conf/uwsgi.ini /app/askbot_app/uwsgi.ini
COPY ./conf/run.sh /app/askbot_app/post-deploy.sh
RUN chmod +x /app/askbot_app/post-deploy.sh

RUN pip3 install dj-database-url

EXPOSE 80
RUN ls -la /app/askbot_app
CMD ["/app/askbot_app/post-deploy.sh"]
