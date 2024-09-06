#!/bin/bash

# DOMINIO CRIADO NO NO-IP
DOMAIN=""

# USUARIO DO NO-IP
NOIPUSER=""

# SENHA DO NO-IP
NOIPPASS=""
# Criando script para atualizar dominio DNS

cat <<EOF>/home/ec2-user/update-domain.sh
#!/bin/bash

IPEC2=\`curl http://checkip.amazonaws.com\`
curl http://$NOIPUSER:$NOIPPASS\\@dynupdate.no-ip.com/nic/update\\?hostname\\=$DOMAIN\\&myip\\=\$IPEC2

EOF

chmod +x /home/ec2-user/update-domain.sh

# Criando daemon para executar o script quando o sistema iniciar

sudo cat <<EOF>/etc/systemd/system/update-dns.service
[Unit]
Description=Servico para atualizar DNS
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/bin/bash /home/ec2-user/update-domain.sh

[Install]
WantedBy=multi-user.target

EOF

# Recarregando o systemctl

sudo systemctl daemon-reload

# Habilitando o daemon para inicalizar junto com o servidor

sudo systemctl enable update-dns
