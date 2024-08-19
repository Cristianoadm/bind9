#!/bin/bash

# Atualiza o sistema e instala o BIND9
sudo apt-get update
sudo apt-get install -y bind9 bind9utils bind9-doc dnsutils

# Configurações no arquivo named.conf.options
sudo bash -c 'cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    auth-nxdomain no;
    listen-on port 53 { localhost; 192.168.0.0/24; };
    allow-query { localhost; 192.168.0.0/24; };
    forwarders { 8.8.8.8; };
    recursion yes;
};
EOF'

# Configuração das zonas no named.conf.local
sudo bash -c 'cat > /etc/bind/named.conf.local <<EOF
zone "meudominio.local" IN {
    type master;
    file "/etc/bind/db.meudominio.local";
};

zone "0.168.192.in-addr.arpa" IN {
    type master;
    file "/etc/bind/reverse.meudominio.local";
};
EOF'

# Configurações de zona no db.meudominio.local
sudo bash -c 'cat > /etc/bind/db.meudominio.local <<EOF
\$TTL 604800
@ IN SOA primary.meudominio.local. root.primary.meudominio.local. (
6          ; Serial
604820     ; Refresh
86600      ; Retry
2419600    ; Expire
604600 )   ; Negative Cache TTL
@ IN NS primary.meudominio.local.
primary IN A 192.168.0.1
meudominio.local. IN MX 10 mail.meudominio.local.
www IN A 192.168.0.50
mail IN A 192.168.0.60
ftp IN CNAME www.meudominio.local.
EOF'

# Configurações de zona no reverse.meudominio.local
sudo bash -c 'cat > /etc/bind/reverse.meudominio.local <<EOF
\$TTL 604800
@ IN SOA meudominio.local. root.meudominio.local. (
21         ; Serial
604820     ; Refresh
864500     ; Retry
2419270    ; Expire
604880 )   ; Negative Cache TTL
@ IN NS primary.meudominio.local.
primary IN A 192.168.0.1
1 IN PTR primary.meudominio.local.
50 IN PTR www.meudominio.local.
60 IN PTR mail.meudominio.local.
EOF'

# Habilita e inicia o serviço BIND9
sudo systemctl enable bind9
sudo systemctl restart bind9

# Verifica a configuração
sudo named-checkconf /etc/bind/named.conf.local
sudo named-checkzone meudominio.local /etc/bind/db.meudominio.local
sudo named-checkzone 0.168.192.in-addr.arpa /etc/bind/reverse.meudominio.local

echo "Configuração concluída. O BIND9 está em execução."
