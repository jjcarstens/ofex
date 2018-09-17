## [0.2.3](https://github.com/jjcarstens/ofex/compare/v0.2.3...v0.2.4) - 2018-09-17
### Added
* Filters file for unsafe & (ampersand) and replaces with `&amp;` escape
* Adjust `Ofex.parse/1` to handle `xmerl` failures with a catch and return an `{:error, %InvalidData{}}` tuple safely instead of just crashing

## [0.2.3](https://github.com/jjcarstens/ofex/compare/v0.2.2...v0.2.3) - 2017-10-22
### Added
* General code cleanup (without function change)
  * Update some styling and formatting
  * Adds dialyxir
* adds `transactions_start_date` and `transactions_end_date` to account responses for verifying transactions date range returned by OFX server.

## [0.2.2](https://github.com/jjcarstens/ofex/compare/v0.2.1...v0.2.2) - 2017-09-27
### Added
* Adds support for parsing dates that are %Y%m%d format

## [0.2.1](https://github.com/jjcarstens/ofex/compare/v0.2.0...v0.2.1) - 2017-04-14
### Added
* empty or unmatched attributes now return `nil` instead of empty strings `""` - #6
* added `Ofex.parse!` to skip data validation so you can parse like it's the wild west :cowboy_hat_face:
* Supports parsing dates with precision and timezones - #5

## [0.2.0](https://github.com/jjcarstens/ofex/compare/v0.1.6...v0.2.0) - 2017-03-17
## ⚠️  - This is a breaking change and may require change in your implementation! - ⚠️
### Added
* Adds support for parsing accounts from SIGNUPMSGSRSV1 message set response which may include multiple accounts
* Refactors `Ofex.parse/1` to support this multi-account parsing and adjusts the return to be a map with `:signon` and `:accounts` keys.

## [0.1.6](https://github.com/jjcarstens/ofex/compare/v0.1.6...v0.2.0) - 2017-02-28
### Added
* Now supports parsing QFX and other files that may be missing XML closing tags for inner fields of a message set.
