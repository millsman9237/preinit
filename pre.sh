#!/bin/bash

# Updates the system and installs docker
apt update; apt upgrade -y; apt install docker.io -y

# Creates admin user
useradd -m -G wheel,docker -s /bin/bash $PREADMIN

# Creates ssh folder and sets permission
mkdir /home/$PREADMIN/.ssh
chmod 700 /home/$PREADMIN/.ssh
touch /home/$PREADMIN/.ssh/authorized_keys
chmod 600 /home/$PREADMIN/.ssh/authorized_keys
chown $PREADMIN:$PREADMIN -R /home/$PREADMIN/.ssh

# Sets password for newly created admin user
echo -e "$PASS\n$PASS\n" | passwd $PREADMIN

# Generates sudoers file
echo -e 'root ALL=(ALL) ALL\n$PREADMIN ALL=(ALL) ALL' > /etc/sudoers

echo -e "$PUBLICKEY" > /home/$PREADMIN/.ssh/authorized_keys

# Generates sshd config
echo -e 'PermitRootLogin no\nPubkeyAuthentication yes\nAuthorizedKeysFile .ssh/authorized_keys\nPasswordAuthentication no\nChallengeResponseAuthentication no\nUsePAM yes\nSubsystem sftp /usr/lib/ssh/sftp-server' > /etc/ssh/sshd_config
# Restarts sshd
systemctl restart sshd

# Initializes Presearch auto updater and node
docker stop presearch-node
docker rm presearch-node
docker stop presearch-auto-updater
docker rm presearch-auto-updater
docker run -d --name presearch-auto-updater --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock presearch/auto-updater --cleanup --interval 900 presearch-auto-updater presearch-node
docker pull presearch/node
docker run -dt --name presearch-node --restart=unless-stopped -v presearch-node-storage:/app/node -e REGISTRATION_CODE=$KEY presearch/node
docker logs -f presearch-node
