# -*- mode: ruby -*-
# vi: set ft=ruby :

VM_COUNT = 2

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 1
  end

  (1..VM_COUNT).each do |i|
    vm_name = i == 1 ? "master" : "worker%01d" % [i-1]
    ip = "172.18.18.#{i+100}"
    config.vm.define vm_name do |host|
      host.vm.hostname = vm_name
      host.vm.network :private_network, ip: ip
    end
  end

  config.vm.provision "install-docker", :type => "shell", :path => "script/install-docker.sh"
  config.vm.provision "install-k8s", :type => "shell", :path => "script/install-k8s.sh"
  config.vm.provision "setup-hosts", :type => "shell", :path => "script/setup-hosts.sh" do |s|
    s.args = ["enp0s8"]
  end
end
