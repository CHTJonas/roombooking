<img width="280" align="right" src="https://raw.githubusercontent.com/CHTJonas/roombooking/master/public/logo-long-black.svg?sanitize=true">

# ADC Room Booking System
This repository hosts the code for the new Room Booking System for the ADC Theatre in Cambridge.
The system is under active development and accordingly there are likely to be some bugs.
The database schema should also not be considered stable.

The site runs as a Ruby on Rails application, backed by a Postgres database.
Background job processing is handled by Sidekiq, backed by a Redis key/value store.
The README assumes you have a basically understanding and working installation of Ruby as well as the Rails framework.
Please [contact me](mailto:charlie@charliejonas.co.uk) if you need help with this.

## Installation
To install ADC-RBS for development purposes you will need to clone this repository, install dependencies and then setup the environment.

1. `git clone https://github.com/CHTJonas/roombooking.git && cd roombooking`
2. `bundle install`
3. `rails roombooking:install`
4. `rails server`

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
