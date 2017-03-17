## [0.2.0](https://github.com/jjcarstens/ofex/commit/cb5e5f012fb5e04bf98de19551b4d0e1191f8030) - 2017-03-17
## ⚠️  - This is a breaking change and may require change in your implementation! - ⚠️
### Added
* Adds support for parsing accounts from SIGNUPMSGSRSV1 message set response which may include multiple accounts
* Refactors `Ofex.parse/1` to support this multi-account parsing and adjusts the return to be a map with `:signon` and `:accounts` keys.

## [0.1.6](https://github.com/jjcarstens/ofex/commit/cb5e5f012fb5e04bf98de19551b4d0e1191f8030) - 2017-02-28
### Added
* Now supports parsing QFX and other files that may be missing XML closing tags for inner fields of a message set.
