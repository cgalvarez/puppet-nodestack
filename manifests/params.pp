# See README.md for usage information
class nodestack::params {
  $nvm_manage_user          = false
  $nvm_manage_dependencies  = true
  $nvm_manage_profile       = true
  $nvm_version              = 'v0.29.0'
  $nvm_repo                 = 'https://github.com/creationix/nvm.git'
  $nvm_refetch              = false
  $node_version_defaults    = {
    'default'     => false,
    'from_source' => false,
  }
}
