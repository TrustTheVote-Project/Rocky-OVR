# TODO Before downloading the latest code, back up existing code base
# Have the app served from a symlinked location, so we can just change the pointer for a quick revert
sudo mkdir -p /var/www/rocky-last-deploy
sudo chown ec2-user /var/www/rocky-last-deploy
sudo chgrp ec2-user /var/www/rocky-last-deploy
sudo mkdir -p /var/www/rocky
sudo chown ec2-user /var/www/rocky
sudo chgrp ec2-user /var/www/rocky
cp -rf /var/www/rocky /var/www/rocky-last-deploy
