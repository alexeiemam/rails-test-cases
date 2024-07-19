docker run \
  -it \
  --mount type=bind,src=.,dst=/usr/app \
  ruby:3.3.4-bullseye \
    bash -cx "ruby /usr/app/7.1/composite-primary-keys/3column.rb"
