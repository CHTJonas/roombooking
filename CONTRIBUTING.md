# Contributing to Room Booking
First off, thanks for taking the time to contribute! :tada::+1:

The following is a set of guidelines for contributing to the ADC Room Booking System. These are recommendation rather than strict rules and it may be appropriate to take them with a pinch of salt in certain circumstances. Use your best judgment, and feel free to propose changes to this document in a pull request.

## How to Contribute?
Reporting bugs is a great way to contribute! Whilst we use [Sentry](https://sentry.io) to monitor and listen for exceptions, it can often be helpful to have a first hand report in order to reproduce the issue. If you can't find any bugs but have an idea for a cool new feature then you can suggest it as an enhancement. If either of these are the case then please open a [new issue](https://github.com/CHTJonas/roombooking/issues/new).

If you're comfortable writing code then feel free to [fork](https://github.com/CHTJonas/roombooking/fork) the repo and open a corresponding [pull request](https://github.com/CHTJonas/roombooking/compare). Remember that this is open source software so please consider the other people who will read your code. Make it look nice for them and document your changes in code comments.

## Getting Started
Before you dive in and start contributing you should familiarise yourself with the overall architecture of the project. The Room Booking System is built on top of the [Ruby on Rails](https://rubyonrails.org/) web framework. Rails was picked because it's an easy framework to get started with and because [Ruby](https://www.ruby-lang.org/en/) is an elegant and natural programming language for beginners. Rails is what's called a MVC (model-view-controller) framework and you should make sure you read the [guides](https://guides.rubyonrails.org) before you start hacking the codebase.

The speed of the app is important - web requests shouldn't take longer than about three or four hundred milliseconds. In order to keep the frontend snappy, as much processing as possible is offloaded to a background job engine. We use [Sidekiq](https://sidekiq.org/) for this purpose. We also use [Redis](https://redis.io/) to cache certain data in-memory for quick retrieval at a later point without the potentially costly time it would take to recompute.

We also use Redis in a few limited circumstances as a persistent key/value store. However the bulk of Room Booking System data is stored in the database for which we use [PostgreSQL](https://www.postgresql.org/).

## Git Commit Messages
* Use the present tense ("Add feature XYZ" not "Added feature XYZ").
* Use the imperative mood ("Add feature XYZ" not "Adds feature XYZ").
* Limit the first line to 72 characters or less.
* Write an extended description after the first line.
* Reference issues and pull requests liberally after the first line.
* When changing documentation or HTML text, include [ci skip] in the commit title.

## Coding Conventions
* Use a single space after list items, operators and method parameters (`[1, 2, 3]` not `[1,2,3]` and `x += 1` not `x+=1`).
* We use HTML+ERB for most dynamic views, and HAML for large static pages.
* Put HTML generators in helpers.
* Put logic in models.
* Put database-querying code in controllers.
* Put complicated workflows in service objects.

## Style Conventions
* Use UNIX-style (LF) line endings.
* End every file with a single blank line.
* Use the UTF-8 character set.
* Indent code blocks using two spaces (please don't use tabs).

## Executive Decisions
Whilst this is an open-source project developed for the benefit of the Cambridge theatre community, there will be times in which we make a significant decision regarding how we maintain the project and what we can or cannot support. We reserve the right to make such executive decisions if necessary. Please also note that changes that are cosmetic in nature and do not add anything substantial to the stability, functionality, or testability of the project will generally not be accepted.

## I've got a question!
If you have an issue with anything then please get in contact. If you query is administrative then it is best directed at the ADC Theatre, otherwise technical question can be addressed to the project coordinator.
