docker run \
  -it \
  --mount type=bind,src=.,dst=/usr/app \
  --mount type=bind,src=/Users/alexeie/code/activerecord_where_assoc,dst=/usr/app/vendor/activerecord_where_assoc \
  ruby:3.3.4-bullseye \
    bash -cx "ruby /usr/app/7.1/composite-primary-keys/3columnwhereassoc.rb"
