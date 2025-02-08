# Changelog
## [0.3.0] - 2024-02-08

### Added
- Added configuration `mappings`; a hash map where `keys` are function names
to be translated to `values`

### Fixed
- Fixed issue where `ignores` would be required

## [0.2.0] - 2024-02-06

Thanks to @bukowa for reporting these issues! :)

### Added
- Added configuration `ignores`; function names added to it will not be
  inserted into the call graph;
- Added configuration `separator`; the value will be used as separator for 
  function names containing spaces.

### Fixed

- Fixed dot syntax issue when function names with spaces are used. Now,
  spaces will be replaced by `_` (customizable by the config `separator`)
- Fixed issue where callbacks names would be empty, leading to dot file syntax 
  issues. The new behavior is as follows:
  * When the debug library reports an empty name, we try looking at the global;
  environment (by comparing the function's pointer value with the environment
  name); if it is not found there, we use the placeholder `_unnamed`. The 
  function is only found in the global environment if it is bound to a name. 
  This still has room for improvements.
