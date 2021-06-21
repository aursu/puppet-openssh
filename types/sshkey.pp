type Openssh::SshKey = Struct[{
  type => Openssh::KeyType,
  key  => Stdlib::Base64,
  name => String,
}]
