# rake db:migrate db:create db:seed RAILS_ENV=production

DIR="/etc/letsencrypt/live/stg2.cojt-sns.work"

if [ ! -d $DIR ];then
certbot certonly -n -m "$EMAIL" --standalone --agree-tos -d stg2.cojt-sns.work
fi
ls $DIR
chmod -R 744 $DIR
rails server -e production