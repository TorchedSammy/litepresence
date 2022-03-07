# Changelog
This project adheres to [Semantic Versioning](https://semver.org).

## [0.2.0] - 2022-03-06
### Added
- Presence is now updated if a *new file* is saved
- New config options:
```lua
config.plugins.litepresence = {
	binPath = '', -- path to binary (default is relative to plugin path)
	projectTime = false, -- whether the elapsed time will be based on project open time or file open time
	clientID = '' -- client id for program (only change if you know)
}
```
- Indicate any Litepresence errors, you can now easily know if the service
dies unexpectedly
### Changed
- Tiny performance change, by @takase1121 ([#5](https://github.com/TorchedSammy/litepresence/pull/5))

## [0.1.0] - 2022-02-11
Initial release

[0.2.0]: https://github.com/TorchedSammy/Litepresence/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/TorchedSammy/Litepresence/releases/tag/v0.1.0
