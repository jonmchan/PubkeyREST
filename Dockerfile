FROM ruby:2.6

RUN gem install bundler

RUN bundle config --global frozen 1

RUN mkdir /data
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4567

ENV SQLITE_FILE_LOCATION /data/keypairs.db

ENTRYPOINT bundle exec ruby main.rb -s Puma -o 0.0.0.0
