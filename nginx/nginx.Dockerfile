FROM nginx

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx-selfsigned.crt /usr/nginx/
COPY nginx-selfsigned.key /usr/nginx/

EXPOSE 80:443
ENTRYPOINT nginx -g 'daemon off;'
