# rake db:migrate db:create db:seed RAILS_ENV=production
certbot certonly -n -m "$EMAIL" --standalone --agree-tos -d api.stg.cojt-sns.work
rails server -e production