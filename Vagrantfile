Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/disco64"
    config.vm.hostname = "ansible-cow"

    config.vm.provider "virtualbox" do |v|
        v.name = "ansible-cow"
        v.memory = 2048
        v.cpus = 2
    end

    config.ssh.insert_key = false

    config.vm.provision "ansible" do |ansible|
        ansible.verbose = true
        ansible.playbook = "main.yml"
        ansible.galaxy_role_file = "requirements.yml"
        ansible.vault_password_file = ".vault_pass"
        # ansible.ask_become_pass = true
      end
  end
