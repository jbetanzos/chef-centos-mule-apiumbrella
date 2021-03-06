# Chef Recipe for JRE 1.7, Maven 3.3, Mule CE 3.5 and API Umbrella
###### If you are not familiar with vagrant check System Requirements section.

This recipe downloads Mule and API Umbrella installation files under `/vagrant/resources/`. I recommend you to test this recipe in a Vagrant box. 

Recipe links the directory `/opt/mule-standalone-3.5.0/apps` to `/vagrant/mule/apps`. If you have a different configuration you need to change the line 56 in file `default.rb`.

This test was created with the box `chef/centos-6.5`, with the Chef Development Kit (find instructions in this [link](https://downloads.chef.io/chef-dk/)). 

This recipe does not show the download file progress, I advise you to download the installation files prior to apply the recipe. Dependencies are:
```
$ wget https://developer.nrel.gov/downloads/api-umbrella/el/6/api-umbrella-0.8.0-1.el6.x86_64.rpm

$ wget https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/3.5.0/mule-standalone-3.5.0.tar.gz
```
## Apply the recipe

You can run this recipe in a local mode with the following command:
```
$ berks vendor cookbooks/
$ sudo chef-client —local-mode —runlist ‘recipe[lyrisdemo]’
```

Make sure you are inside the `lyrisdemo` recipe directory. Port that are open to be seen in the host machine are: 80, 443, 8081

Download the demo application using this [link](https://dl.dropboxusercontent.com/u/77884581/apps/mule/asi-demo.zip) and put the .zip file in `mule/apps`

You can test the Mule application by making this request
```
http://33.33.33.93:8081/API/mailing_list.html?type=list&input=%3CDATASET%3E%20%20%3CSITE_ID%3E2010001045%3C%2FSITE_ID%3E%20%20%3CMLID%3E292401%3C%2FMLID%3E%20%20%3CDATA%20type%3D%22extra%22%20id%3D%22password%22%3EUus892jsoO%3C%2FDATA%3E%20%20%3CDATA%20type%3D%22list-id%22%3E11589%3C%2FDATA%3E%3C%2FDATASET%3E
```
The IP depends on how you configured your vagrant machine.

## Additional Information
Make sure Mule is running by executing this command from your host machine.
```
$ vagrant ssh -c ‘sudo /opt/mule/bin/mule status’
```
If Mule is not running execute the following command
```
$ vagrant ssh -c ‘sudo /opt/mule/bin/mule start’
```

## API Umbrella configuration
API Umbrella will be installed after you `vagrant up` your box. Make sure API Umbrella is running with `vagrant ssh -c “sudo /etc/init.d/api-umbrella status”` if not then execute `vagrant ssh -c “sudo /etc/init.d/api-umbrella start”` or `vagrant reload`

### Monitor an API
Login into API Umbrella for this configuration use `https://33.33.33.93/admin`

Go to *Configuration > API Backends*, and apply the following configuration:
```
Name: demo
Banckend: http
Server: http://33.33.33.93:8081
Frontend Host: 33.33.33.93
Backend Host: 33.33.33.93
Frontend Prefix: /
Backend Prefix: /

#### Global Request Settings
API Key Checks: Disable - API keys are optional
Rate limit: Custom rate limits
Duration: 1 minute
Limit by: IP Address
Limit: 5 request
Primary [x]
Anonymous Rate Limit Behaviour: IP Only
Authenticated Rate Limit Behaviour: All Limits
```
Above configurations will monitor the API project by allowing 5 calls per minute by IP. In order to this changes take affect save the configuration and then go to *Configuration > Publish Changes*, check the demo configuration and *Publish*

Open a browser and test the API manager by calling more than 5 times the service `https://33.33.33.93/API/mailing_list.html?type=list&input=%3CDATASET%3E%20%20%3CSITE_ID%3E2010001045%3C%2FSITE_ID%3E%20%20%3CMLID%3E292401%3C%2FMLID%3E%20%20%3CDATA%20type%3D%22extra%22%20id%3D%22password%22%3EUus892jsoO%3C%2FDATA%3E%20%20%3CDATA%20type%3D%22list-id%22%3E11589%3C%2FDATA%3E%3C%2FDATASET%3E` you will get a text like this:
```
<DATASET>
    <TYPE>success</TYPE>
    <RECORD>
        <DATA type=“state”>uploaded</DATA>
    </RECORD>
</DATASET>
```
## System Requirements
### VirtualBox installation
Install VirtualBox from this [location](https://www.virtualbox.org/wiki/Downloads). Follow the installer instructions. 

### Vagrant installation
Install vagrant from this [site](http://www.vagrantup.com/downloads). Following the installer instruction. After you install Vagrant you will have the `vagrant` command available. 

### Git installation
Download and install Git from using this [link](https://git-scm.com/downloads). After you install Git you will have available the `git` command.

### Basic Commands

Using your OS console (Terminal, Console Windows, Bash) execute the following command in order to create your vagrant environment.
```
$ vagrant init chef/centos-6.5
```

Above command will generate the file `Vagrantfile`. Open the file and add the following lines after `config.vm.box = “chef/centos-6.5”`:
```
	config.vbguest.auto_update = false
  config.vm.network “private_network”, ip: “33.33.33.93”
  config.nfs.map_uid = 0
  config.nfs.map_gid = 0
  config.vm.provider “virtualbox” do |vb|
      vb.memory = “3500”
  end
  config.vm.hostname = ‘api.lyrisdemo.com’
  config.ssh.username = “vagrant”
  config.ssh.shell = “bash -l”
  config.ssh.keep_alive = true
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = false
```
Now you have vagrant ready, under the same directory where you have your Vagrantfile create the following files structure.
```
├── Vagrantfile
├── mule
│   └── apps
├── recipes
└── resources
    ├── api-umbrella-0.8.0-1.el6.x86_64.rpm
    ├── chef-server-core-12.1.2-1.el6.x86_64.rpm
    ├── chefdk-0.7.0-1.el6.x86_64.rpm
    └── mule-standalone-3.5.0.tar.gz
```

Check the first section of this document to make sure you have the `.rpm` and `.tar.gz` files.

Now you can clone the repository under the `recipes` directory
```
$ git clone https://github.com/jbetanzos/puppet-centos-mule-apiumbrella.git
```

Then `vagrant up`. You need to install Chef Development Kit make sure you have downloaded the file `chefdk-0.7.0-1.el6.x86_64.rpm`. Then hit `vagrant ssh -c “sudo yum install -y /vagrant/resources/chefdk-0.7.0-1.el6.x86_64.rpm”`

You are ready to continue with section *Apply the recipe* in this document.