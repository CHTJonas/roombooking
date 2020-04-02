<img width="280" align="right" src="https://raw.githubusercontent.com/CHTJonas/roombooking/master/public/logo-long-black.svg?sanitize=true">

# ADC Room Booking System

[![Ruby Version](https://img.shields.io/badge/Ruby-v2.6.6-brightgreen.svg)](https://www.ruby-lang.org/en/)
[![Rails Version](https://img.shields.io/badge/Rails-v6.0.2-brightgreen.svg)](http://rubyonrails.org/)
[![Build Status](https://github.com/CHTJonas/roombooking/workflows/CI%20CD/badge.svg)](https://launch-editor.github.com/actions?workflowID=CI%20CD&event=push&nwo=CHTJonas%2Froombooking)
[![Test Coverage](https://codecov.io/gh/CHTJonas/roombooking/branch/master/graph/badge.svg)](https://codecov.io/gh/CHTJonas/roombooking)

This repository hosts the code for the [ADC Theatre's](https://www.adctheatre.com) new Room Booking System.
The site runs as a [Ruby on Rails](https://rubyonrails.org/) application with background job processing handled by [Sidekiq](https://sidekiq.org/).
[Postgres](https://www.postgresql.org/) is used as the backend database of choice and [Redis](https://redis.io/) to store in-memory data.

## Installation
There are two officially supported methods of installation:

1. Docker is the preferred choice for those running Windows, or for people who want to get hands on and coding as soon as possible.
2. A native installation is more useful for developing advanced features, testing & instrumenting or for those that have trouble with the Docker process. It does, however, require you to be running a [UNIX-like](https://en.wikipedia.org/wiki/Unix-like) operating system.

During the setup you'll be prompted for your Camdram API credentials which you can obtain by registering [here](https://www.camdram.net/api/apps/new).

### Docker Install
[Docker](https://www.docker.com/get-started) is a lightning-fast way to get a development environment setup with minimal fuss by running virtualised containers on your machine.
This cross-platform process should work on Windows, macOS and Linux, although there will be something of a performance degradation on macOS when compared to a native installation.

1. `git clone https://github.com/CHTJonas/roombooking.git`
2. `cd roombooking`
3. `docker-compose build`
4. `docker-compose run --rm web "bin/setup"`
5. `docker-compose up`

This will spin up several Docker containers and the logs will appear in the foreground of your terminal window.
Press Ctrl+C *once* to gracefully stop and bring down all containers.
If you need to rebuild the Docker container for any reason (eg. after installing new Gems) then type `docker-compose down --volumes --remove-orphans` at the terminal prompt and repeat from step 3 above.
If you're developing on top of Microsoft Windows then you need to ensure that you checkout and checkin source code with UNIX-style line endings (LF).
This can usually be achieved by running `git clone https://github.com/CHTJonas/roombooking.git --config core.autocrlf=input` and/or by working with a modern text editor or IDE that preserves line endings.

### Native Install
Installing from source is relatively easy and should work on anything UNIX-like including the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
You'll need both Postgres and Redis setup locally which, if you're running Debian or Ubuntu, can be achieved by typing `sudo apt install postgresql redis` at a terminal.
Note that your user account will need `CREATE/DROP DATABASE` privileges for the initial setup but not thereafter.

1. `git clone https://github.com/CHTJonas/roombooking.git`
2. `cd roombooking`
3. `bundle install -j4`
4. `bin/setup`
5. `rails server`

This will start the Rails application (web) server in the foreground of the current terminal.
To optionally start Sidekiq to process background jobs you can run `bundle exec sidekiq` in a separate terminal.
Pressing Ctrl+C will interrupt and shutdown either one of these.

## Contributing
Anyone may contribute to the project and bug reports or feature requests are warmly welcomed!
Please familiarise yourself with the [contributing guidelines](https://github.com/CHTJonas/roombooking/blob/master/CONTRIBUTING.md) before you get started.
If you decide you want to write some code yourself:

1. Fork the repo (https://github.com/CHTJonas/roombooking/fork).
2. Create a feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push -u origin my-new-feature`).
5. Create a new Pull Request.

When coding, please try to update any tests your code affects or, even better, add new tests where none currently exist!
Don't worry if you're not too sure about this - if you open a Pull Request we can provide some assistance.
To run the full test suite, type the following into your terminal (or append to `docker-compose run --rm web`):

1. `rails test`
2. `rails test:system`

Please ensure your code adheres to the following basic style rules.
You should be able to do this automatically by installing an [EditorConfig compatible](https://editorconfig.org/#download) text editor/IDE, or a plugin.

* Use UNIX-style (LF) line endings.
* Terminate every file with a single blank line at the end.
* Remove any whitespace characters preceding new lines.
* Use the UTF-8 character set.
* Indent code blocks using two spaces (please don't use tabs).

Management of the project is meritocratic; those who have a reasonable number of accepted contributions will be granted access to commit straight to the `master` branch of this repository.

## Copyright
Copyright (c) 2018–2020 Charlie Jonas.
The ADC Room Booking System software is released under Version 3 of the GNU General Public License.
See the LICENSE file for full details.
