Facter.add('sshpubkey_root') do
  setcode do
    if File.exist?('/root/.ssh/id_rsa.pub')
      File.read('/root/.ssh/id_rsa.pub').split(%r{\s+}, 3)
    elsif File.exist?('/root/.ssh/id_dsa.pub')
      File.read('/root/.ssh/id_dsa.pub').split(%r{\s+}, 3)
    else
      nil
    end
  end
end
