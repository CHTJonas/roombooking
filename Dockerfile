FROM ruby:2.7.2

# Install apt-transport-https
RUN apt-get update
RUN apt-get install -y apt-transport-https

# Add NodeJS repo
RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo "deb https://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/node.list

# Add Yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install packages
RUN apt-get update
RUN apt-get install -y nodejs yarn postgresql-client nano vim

# Clean up
RUN apt-get -q clean
RUN rm -rf /var/lib/apt/lists

WORKDIR /usr/src/app
ENV DISABLE_SPRING 1

# Install Ruby dependencies
COPY Gemfile* ./
RUN gem install bundler
RUN bundle install --jobs 20 --retry 5

# Install JavaScript dependencies
COPY yarn.lock ./
RUN yarn install
RUN yarn check --integrity

ENTRYPOINT ["bundle", "exec"]

CMD ["rails", "server", "-b", "0.0.0.0"]
