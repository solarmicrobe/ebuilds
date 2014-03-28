# Vagrant configuration
Vagrant.configure("2") do |config|
  config.vm.define 'testmaching' do |conf|
    conf.vm.box = "gentoo-dev"
    conf.vm.box_url = "https://seedrs.box.com/shared/static/6cg94mkdtuz3baoy8zl8.box"
    # conf.vm.network "public_network", :bridge => 'en0: Wi-Fi (AirPort)'
    
    conf.vm.provider "virtualbox" do |v|
      v.memory = 256
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end
end
