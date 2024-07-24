# Run tests for rails apps that use activerecord models with composite primary keys
docker run \
  -it \
  --mount type=bind,src=.,dst=/usr/app \
  ruby:3.3.4-bullseye \
    bash -cx "ruby /usr/app/7.1/composite-primary-keys/3column.rb"

# Run tests for rails apps that include and use activerecord_where_assoc activerecord models that have composite primary keys
# assumes activerecord_where_assoc gem directory is at the directory specify in the --mount 
docker run \
  -it \
  --mount type=bind,src=.,dst=/usr/app \
  --mount type=bind,src=/Users/alexeie/code/activerecord_where_assoc,dst=/usr/app/vendor/activerecord_where_assoc \
  ruby:3.3.4-bullseye \
    bash -cx "ruby /usr/app/7.1/composite-primary-keys/3columnwhereassoc.rb"

# Run activerecord_where_assoc gem tests 
# (Assumes it is run from the root of activerecord_where_assoc gem directory)
docker run \
  -it \
  --mount type=bind,src=.,dst=/usr/app \
  ruby:3.3.4-bullseye \
    bash -cx "cd /usr/app; bundle install; rake test"
