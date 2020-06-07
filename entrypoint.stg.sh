# rake db:migrate db:create db:seed RAILS_ENV=production

DIR="/etc/letsencrypt/live/api.stg.cojt-sns.work"

if [ ! -d $DIR ];then
certbot certonly -n -m "$EMAIL" --standalone --agree-tos -d api.stg.cojt-sns.work
fi
rails server -d -e production