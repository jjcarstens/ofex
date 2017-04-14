## [0.2.1](https://github.com/jjcarstens/ofex/compare/v0.2.0...v0.2.1) - 2017-04-14
## ⚠️  - This is a breaking change and may require change in your implementation! - ⚠️
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
