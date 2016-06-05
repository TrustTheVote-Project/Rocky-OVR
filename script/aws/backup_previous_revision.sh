# TODO Before downloading the latest code, back up existing code base
# Have the app served from a symlinked location, so we can just change the pointer for a quick revert
mkdir -p /var/www/rocky-last-deploy
cp -r /var/www/rocky/* /var/www/rocky-last-deploy/
