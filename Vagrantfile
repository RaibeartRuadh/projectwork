# -*- mode: ruby -*-
# vim: set ft=ruby :
# RR

NODE_PORT_GUEST = 9100
NODE_PORT_HOST = 9100
PROM_PORT_GUEST = 9090
PROM_PORT_HOST = 9090
GRAFANA_PORT_GUEST = 3000
GRAFANA_PORT_HOST = 3000


MACHINES = {
  fwd: {
    box_name: 'centos/7',
    net: [
      { ip: '192.168.100.10', adapter:2, netmask: '255.255.255.0' },
      { ip: '192.168.255.1', adapter: 3, netmask: '255.255.255.252', virtualbox__intnet: 'dmz' },
    ]
  },
  front: {
    box_name: "centos/7",
    net: [
      { ip: '192.168.100.11', netmask: '255.255.255.0' },
      { ip: '192.168.255.2', netmask: '255.255.255.252', virtualbox__intnet: 'dmz' },
    ]
  },
  web: {
    box_name: "centos/7",
    net: [{ ip: '192.168.100.12', netmask: '255.255.255.0' },]
  },
  db: {
    box_name: "centos/7",
    net: [{ ip: '192.168.100.13', netmask: '255.255.255.0' },]
  },
  journal: {
    box_name: "centos/7",
    net: [{ ip: '192.168.100.14', netmask: '255.255.255.0' },]
  },
  backup: {
    box_name: "centos/7",
    net: [ { ip: '192.168.100.15', netmask: '255.255.255.0' },  ]
  },
}
#################################################################
Vagrant.configure("2") do |config|
  ENV['LC_ALL']="en_US.UTF-8"
  config.vm.synced_folder '.', '/vagrant', disabled: true
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      boxconfig[:net].each do |ipconf|
        box.vm.network 'private_network', ipconf
      end
      box.vm.network 'public_network', boxconfig[:public] if boxconfig.key?(:public)
      box.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "1024"]
      box.vm.provision "shell", path: "config/sshscript.sh"
     end
   end
 end
#################################################################
  config.vm.define 'fwd' do |fwd|
    fwd.vm.provision 'shell', run: 'always', path: "config/firewall.sh"
  end
  
  config.vm.define 'db' do |db|
  db.vm.network "forwarded_port", host: NODE_PORT_HOST, guest: NODE_PORT_GUEST
  db.vm.network "forwarded_port", host: PROM_PORT_HOST, guest: PROM_PORT_GUEST
  db.vm.network "forwarded_port", host: GRAFANA_PORT_HOST, guest: GRAFANA_PORT_GUEST 
  end
  
  config.vm.define 'backup' do |backup|
    backup.vm.provision :ansible do |ansible|
      ansible.limit = "all"
      #ansible.playbook = "requirements.yml"
      ansible.playbook = "playbook/main.yml"
      ansible.inventory_path = "playbook/hosts"
      #ansible.verbose = "v"
    end
  end
end
