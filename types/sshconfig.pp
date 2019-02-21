type Openssh::SshConfig = Hash[
    Openssh::ClientOption,
    Variant[
      String,
      Integer,
      Array[String, 1],
    ]
]
