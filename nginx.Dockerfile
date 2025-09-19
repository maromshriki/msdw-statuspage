FROM nginx:latest
WORKDIR /etc/
COPY status-page.conf /etc/nginx/conf.d/default.conf
COPY statuspage/static /usr/share/nginx/html/
