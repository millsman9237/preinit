wget -O pre.sh https://raw.githubusercontent.com/millsman9237/preinit/main/pre.sh
chmod 755 pre.sh
chmod +x pre.sh
export PREADMIN='admin_name_here'
export PASS='admin_password_here'
export PUBLICKEY='ssh_key_here'
export KEY='presearch_registration_code_here'
./pre.sh
