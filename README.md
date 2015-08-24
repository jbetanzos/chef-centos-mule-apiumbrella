# Chef Recipe for JRE 1.8, Maven 3.3, Mule CE 3.5 and API Umbrella

This recipe downloads Mule and API Umbrella installation files under `/vagrant/resources/`. I recommend you to test this recipe in a Vagrant box. 

This test was created with the box `chef/centos-6.5`, with the Chef Development Kit (find instructions in this [link](https://downloads.chef.io/chef-dk/)). 

This recipe does not show the download file progress, I advise you to download the installation files prior to apply the recipe. Dependencies are:
```
$ wget https://developer.nrel.gov/downloads/api-umbrella/el/6/api-umbrella-0.8.0-1.el6.x86_64.rpm

$ wget https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/3.5.0/mule-standalone-3.5.0.tar.gz
```

You can run this recipe in a local mode with the following command:
```
$ berks vendor cookbooks/
$ sudo chef-client —local-mode —runlist ‘recipe[lyrisdemo]’
```
Make sure you are inside the lyrisdemo recipe directory