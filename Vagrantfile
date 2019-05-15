$initScript = <<SCRIPT
yum update -y
yum install epel-release git -y
git clone https://github.com/jodyhuntatx/dap-demo-env.git
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "dap-demo-env"
  config.vm.network "private_network", ip: "192.168.3.100"

  config.vm.provision "shell", inline: $initScript

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"
    vb.cpus = "2"
  end
end
