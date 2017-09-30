Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  (1..2).each do |i|
    config.vm.define "node#{i}" do |node|
      # see https://www.vagrantup.com/docs/networking/public_network.html for details
      # NOTE: you will probably need to change IPs here and in bootstrap.sh
      # NOTE: you will probably want to set another bridge or not specify it and choose it when you run vagrant up
      node.vm.network "public_network", ip: "192.168.1.15#{i}", bridge: "en0: Wi-Fi (AirPort)"
      node.vm.provision :shell, path: "bootstrap.sh"
    end
  end
end
