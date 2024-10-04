# SEU DOMINIO
DOMINIO=""

cat <<EOF>/etc/nginx/nginx.conf

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

	upstream fastapi {
		server localhost:8000;
		}
	upstream flask {
		server localhost:5000;
		}
    server {
        listen       443 ssl http2;
        root         /usr/share/nginx/html;
        ssl_certificate "/etc/letsencrypt/live/$DOMINIO/fullchain.pem";
        ssl_certificate_key "/etc/letsencrypt/live/$DOMINIO/privkey.pem";
	location /api {
		proxy_pass http://fastapi;
		}
	location / {
		proxy_pass http://flask;
		}
	}

}

EOF

systemctl restart nginx
