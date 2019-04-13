<img width="280" align="right" src="https://raw.githubusercontent.com/CHTJonas/roombooking/master/public/logo-long-black.svg?sanitize=true">

# ADC Room Booking System

[![Ruby Version](https://img.shields.io/badge/Ruby-v2.6.1-brightgreen.svg)](https://www.ruby-lang.org/en/)
[![Rails Version](https://img.shields.io/badge/Rails-v5.2.3-brightgreen.svg)](http://rubyonrails.org/)
[![Security Warnings](https://hakiri.io/github/CHTJonas/roombooking/master.svg)](https://hakiri.io/github/CHTJonas/roombooking/master)

This repository hosts the code for the new Room Booking System for the ADC Theatre in Cambridge.
The system is under active development and accordingly there are likely to be some bugs.
The database schema should also not be considered stable.

The site runs as a Ruby on Rails application, backed by a Postgres database.
Background job processing is handled by Sidekiq, backed by a Redis key/value store.
The README assumes you have a basically understanding and working installation of Ruby as well as the Rails framework.
Please [contact me](mailto:charlie@charliejonas.co.uk) if you need help with this.

## Installation
### Native Install
To install ADC-RBS for development purposes you will need to clone this repository, install dependencies and then setup the environment.
Your machine needs to be running Postgres and Redis locally, and your user account will need `CREATE/DROP DATABASE` privileges.

1. `git clone https://github.com/CHTJonas/roombooking.git && cd roombooking`
2. `bundle install`
3. `cp .env.local.example .env.local && nano .env.local`
4. `rails roombooking:install`
5. `rails server`

### Docker Install
The [Docker](https://www.docker.com/get-started) installation procedure is somewhat incomplete and may not work very smoothly.
There appears to be a significant performance degradation using Docker when compared to a native installation.
Contributions with improvements to the process would be warmly welcomed!
Alternatively please kindly report any issues through the GitHub bug tracker.
1. `git clone https://github.com/CHTJonas/roombooking.git && cd roombooking`
2. `docker-compose build`
3. `docker-compose run --rm web "bundle exec rake db:create db:migrate roombooking:search:setup"`
4. `docker-compose run --rm web "bundle exec rake db:seed"`
5. `docker-compose up`

To reset the Docker engine and all containers run `docker-compose down --rmi all -v --remove-orphans && rm -rf tmp/pids/*`.


## Contributing
Bug reports, enhancements and pull requests are welcome.
If you think this is something you can do yourself:

1. Fork the repo (https://github.com/CHTJonas/roombooking/fork).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push -u origin my-new-feature`).
5. Create a new Pull Request.

## Copyright
Copyright (c) 2018-2019 Charlie Jonas.
The ADC Room Booking System software is released under Version 3 of the GNU General Public License.
See the LICENSE file for full details.
