FROM ruby:2.6.3

# Make NodeJS and Yarn
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install dependencies and perform clean-up
RUN apt-get update -qq
RUN apt-get install -y build-essential nodejs yarn postgresql-client nano vim
RUN apt-get -q clean
RUN rm -rf /var/lib/apt/lists

WORKDIR /usr/src/app
ENV RAILS_ENV development

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
