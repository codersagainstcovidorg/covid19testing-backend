FROM python:3.7-slim

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    nginx \
    wget \
    supervisor \
    libpq-dev \
    build-essential \
  && wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 -O /bin/confd \
  && apt-get remove -y wget \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

ENV USER="app"
ENV WORKDIR="/app"
ENV UWSGI_CHEAPER 2
ENV UWSGI_PROCESSES 16
ENV UWSGI_INI /app/uwsgi.ini
ENV NGINX_MAX_UPLOAD 50m

COPY docker/uwsgi.ini /etc/uwsgi/
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx_server.conf /etc/nginx/conf.d/nginx.conf
RUN printf "client_max_body_size $NGINX_MAX_UPLOAD;" > /etc/nginx/conf.d/upload.conf

# Set up workdir
RUN useradd -ms /bin/bash ${USER} && mkdir ${WORKDIR} && chown -R ${USER}:${USER} ${WORKDIR}
RUN chown -R ${USER}:${USER} /var/lib/nginx

WORKDIR ${WORKDIR}

COPY . .

# Supervisord uses a user directive to drop privileges 
ENTRYPOINT [ "docker/entrypoint.sh" ]
CMD [ "start" ]