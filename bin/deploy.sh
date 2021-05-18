#! /usr/bin/env sh

export RAILS_ROOT=`realpath $(dirname $0)/..`
name=klarschiff-backoffice
deploy_path=$RAILS_ROOT/bin/deploy

# echo " * deploying /etc/cron.d/$name"
# sudo cp $deploy_path/crontab /etc/cron.d/$name
# sudo chmod 644 /etc/cron.d/$name

# echo " * deploying /etc/logrotate.d/$name"
# sudo cp $deploy_path/logrotate /etc/logrotate.d/$name

echo " * deploying /etc/systemd/system/$name.service"
`rvm wrapper show ruby` -r erb -e 'puts ERB.new(IO.read("'$deploy_path'/'$name'.service.erb")).result' | \
  sudo tee /etc/systemd/system/$name.service > /dev/null
sudo systemctl daemon-reload
sudo systemctl enable $name.service
sudo systemctl restart $name.service
