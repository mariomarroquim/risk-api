# Cloudwalk Risk API

This is an example of a Ruby on Rails web service (API-only mode) to check transactions for fraud.

## Instructions

This web service requires Ruby 3.2.2, Ruby on Rails 7.1.1, and the latest version of PostgreSQL. The installation
instructions are the regular ones for any Ruby on Rails project. There are Docker files to get you started.

## Highlights

* This project uses the latest Ruby, Ruby on Rails, and PostgreSQL versions.
* It comes with Brakeman and Rubocop, for code security and quality checking, respectively.
* It also comes with Bundler Audit to inspect security issues among required external gems.
* Automated tests are present and cover 100% of the code that provides the functionality.
* There are Github Actions to run Brakeman, Rubocop, Bundler Audit, and tests after each commit.
* In Production, this project uses the `error` log level and Lograge to reduce log size.
* This API-only project is expected to have lower startup times and a smaller CPU/memory footprint.
* There are places where optimization is possible. Please, read the comments about how they could be done.

## Support

You can contact me at mariomarroquim@gmail.com.
