FROM ubuntu:20.04 

LABEL maintainer="Austin Hanson <berdon@gmail.com>"

RUN apt-get update && apt-get -y upgrade && apt-get install python3-pip libsasl2-dev python3-dev libldap2-dev libssl-dev git libjpeg-dev -y

VOLUME ["/data"]

# Install askbot
# nicht: RUN pip install askbot

RUN pip3 install --upgrade pip
# RUN pip3 install akismet
# RUN pip3 install Pillow

RUN git clone https://github.com/ASKBOT/askbot-devel

WORKDIR /askbot-devel
RUN ls -la 
RUN git checkout 0.11.x
RUN git status

RUN python3 setup.py build
RUN python3 setup.py install

# Setup askbot (defaults to using sqlite)
RUN python3 `which askbot-setup` -n /app -e 2 -d /data/askbot.db

RUN ls -la /

WORKDIR /

RUN ls -la /app/askbot_app
# Disable debug mode (see readme on enabling)
# RUN sed -i "s|^DEBUG = True|DEBUG = False|" /app/askbot_app/settings.py

# # Some garbage handling because askbot maybe doesn't pin dependency versions?
# RUN pip install -U --force-reinstall six==1.10.0
# RUN pip install uWSGI==2.0.11 wsgiref==0.1.2
RUN pip3 install uWSGI
# wsgiref

# Necessary for the optional LDAP support (which I'm dictating as being required functionally optional)
RUN pip3 install python-ldap

# # WORKDIR /app

# # Append some stuff to add to python's import path and allow for settings overriding
COPY ./conf/settings-override.py /app/askbot_app/settings-override.py
RUN cat /app/askbot_app/settings-override.py >> /app/askbot_app/settings.py
# RUN rm /app/settings-override.py

# # Copy over some runtime stuff
COPY ./conf/uwsgi.ini /app/askbot_app/uwsgi.ini
COPY ./conf/run.sh /app/askbot_app/post-deploy.sh
RUN chmod +x /app/askbot_app/post-deploy.sh

RUN pip3 install dj-database-url

EXPOSE 80
RUN ls -la /app/askbot_app
CMD ["/app/askbot_app/post-deploy.sh"]
