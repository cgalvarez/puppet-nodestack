# Class: nodestack
#
# This module manages multiple node.js stacks through NVM and installs desired
# packages.
#
# Parameters:
#
# [*nvm_user*]
#   Sets the user that will install NVM. Must be a string.
#
# [*nvm_user_home*]
#   Indicates the user's home. Only used when `manage_user` is set to `true`.
#   Must be an absolute path. Defaults to "/home/${user}".
#
# [*nvm_dir*]
#   Sets the directory where NVM is going to be installed.
#   Must be an absolute path. Defaults to "/home/${user}/.nvm".
#
# [*nvm_profile_path*]
#   Sets the profile file where the nvm.sh is going to be loaded. Only used
#   when manage_profile is set to true (default behaviour). Must be an absolute
#   path. Defaults  to "/home/${user}/.bashrc".
#
# [*nvm_version*]
#   Version of NVM that is going to be installed. Can point to any git
#   reference of the NVM project (or the repo set in ǹvm_repo parameter).
#   Must be a valid semver string. Defaults to 'v0.29.0'.
#
# [*nvm_manage_user*]
#   Sets if the selected user will be created if not exists.
#   Must be boolean. Defaults to `false`.
#
# [*nvm_manage_dependencies*]
#   Sets if the module will manage the git, wget, make package dependencies.
#   Must be boolean. Defaults to `true`.
#
# [*nvm_manage_profile*]
#   Sets if the module will add the nvm.sh file to the user profile.
#   Must be boolean. Defaults to `true`.
#
# [*nvm_repo*]
#   Sets the NVM repo url that is going to be cloned.
#   Must be a valid URL (starting with the http(s) protocol).
#   Defaults to 'https://github.com/creationix/nvm'.
#
# [*nvm_refetch*]
#   Sets if the repo should be fetched again. Must be boolean.
#   Defaults to `false`.
#
# [*versions*]
#   Sets the Node.js/iojs versions to install. Must be a hash, with the key
#   being the version (semver string) to install, and the value being a hash
#   with any of the following parameters:
#
#   * user: Sets the user that will install Node.js/iojs.
#     Must be a string. Defaults to `$nvm_user`.
#   * default: Whether to set this Node.js/iojs version as default.
#     Defaults to `false`.
#   * source: Whether to install Node.js/iojs from sources.
#     Defaults to `false`.
#
#   The version string must be a valid special default alias for nvm (node,
#   iojs, stable, unstable, or a valid semver string. See
#   https://github.com/creationix/nvm for all possible values.
#   Valid examples are 'node', 'iojs', '0.10.2', 'stable', 'unstable', 'v0.13',
#   '0.11', 'iojs-v1.0', 'iojs-v1.0.3'.
#
# [*packages*]
#   
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class nodestack(
  # Parameters for artberri/nvm
  $nvm_user,
  $nvm_user_home            = undef,
  $nvm_dir                  = undef,
  $nvm_profile_path         = undef,
  $nvm_version              = $::nodestack::params::nvm_version,
  $nvm_manage_user          = $::nodestack::params::nvm_manage_user,
  $nvm_manage_dependencies  = $::nodestack::params::nvm_manage_dependencies,
  $nvm_manage_profile       = $::nodestack::params::nvm_manage_profile,
  $nvm_repo                 = $::nodestack::params::nvm_repo,
  $nvm_refetch              = $::nodestack::params::nvm_refetch,
  $versions                 = {},
  $packages                 = {},
) inherits ::nodestack::params {

  # Perform validations
  validate_string($nvm_user)
  validate_bool($nvm_refetch, $nvm_manage_user, $nvm_manage_dependencies, $nvm_manage_profile)
  validate_re($nvm_version, '^v?(\d+\.)?(\d+\.)?(\*|\d+)$')
  validate_re($nvm_repo, '^https?://.*')
  validate_hash($versions)
  if $nvm_user_home != undef {
    validate_absolute_path($nvm_user_home)
  }
  if $nvm_dir != undef {
    validate_absolute_path($nvm_dir)
  }
  if $nvm_profile_path != undef {
    validate_absolute_path($nvm_profile_path)
  }

  # Install nvm to manage Node.js installations
  class { 'nvm':
    user                => $nvm_user,
    home                => pick_default($nvm_user_home, "/home/${nvm_user}"),
    nvm_dir             => pick_default($nvm_dir, "/home/${nvm_user}/.nvm"),
    profile_path        => pick_default($nvm_profile_path, "/home/${nvm_user}/.bashrc"),
    version             => $nvm_version,
    manage_user         => $nvm_manage_user,
    manage_dependencies => $nvm_manage_dependencies,
    manage_profile      => $nvm_manage_profile,
    nvm_repo            => $nvm_repo,
    refetch             => $nvm_refetch,
  }

  # Install requested Node.js/iojs versions
  $defaults = {
    user    => $nvm_user,
    nvm_dir => pick_default($nvm_dir, "/home/${nvm_user}/.nvm"),
  }
  $versions.each |String $version, Hash $params| {
    # Perform validations
    validate_re($version, '^(v?(\d+\.)?(\d+\.)?(\d+)|iojs(-v(\d+\.)?(\d+\.)?(\d+))?|node|stable|unstable|)$')
    if has_key($params, 'user') {
      validate_string($params['user'])
    }
    create_resources('nvm::node::install',
      { $version => $params },
      merge($::nodestack::params::node_version_defaults, $defaults)
    )
  }


}