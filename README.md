statsd-graphite-gdash-vagrant-centos6
=====================================

A Vagrant CentOS 6 Virtual Machine (VM) per-configured for gdash viewing onto graphite, includes carbon, whisper and statsd

overview
========

The project contains a workspace that allows you to create a Vagrant box based on CentOS 6 that contains all the necessary requirements to visualise a [gdash](https://github.com/ripienaar/gdash) based [graphite](http://graphite.wikidot.com/) solution.  The virtual machine also provides a statsd server that can be utilised by the host to push stats into graphite.  

The VM is setup with hostonly networking on 33.33.33.10 and a mountpoint created in the hosts local directory called ./dashboards that can be used to configure gdash dashboards in the VM.  gdash and graphites web interfaces are port forwarded on the host to ports 9090 and 9091.


installation and use
========

The solution assumes that you have [virtualbox](https://www.virtualbox.org/) and [vagrant](http://vagrantup.com/) already setup on your host machine.

Create the dashboards directory before starting.

      mkdir ./dashboards

      wget https://raw.github.com/alrighttheresham/statsd-graphite-gdash-vagrant-centos6/master/Vagrantfile

      vagrant box add CentOS-6.3-x86_64-minimal https://dl.dropbox.com/u/6164051/CentOS-6.3-x86_64-minimal.box 

      vagrant up 

Assuming no issues at this point the VM will be running and can be accessed with 

      vagrant ssh

This will provide console access to the VM.


building
========

**NOTE** you only need to do this if my dropbox VM disappears.

This has only be tested on OSX Mountain Lion.  

Before doing this on OSX I had to download the latest version of ruby, I use [macports](http://www.macports.org/) for this. 

        sudo port install ruby19 +nosuffix
        ruby --version
        ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-darwin11.4.0]

I used [veewee](https://github.com/jedi4ever/veewee) to generate a skeleton project, what has been uploaded to github is the a tailoring of this generated project.

At this point you need to go off and download the appropriate base iso file and place this in the iso directory.

At this point we’re pretty much ready to build our base box. Running the build command below will pop up an automated install Virtual Box window. You can observe the install progress.

        vagrant basebox build 'CentOS-6.3-x86_64-minimal'

NOTE: Do not hit enter in the Virtualbox screen to start the install, if you do it will use the kickstart from the mounted iso.

Before exporting to the vm to a .box file we need to validate it.

        vagrant basebox validate CentOS-6.3-x86_64-minimal 

If all went well, we can now export our base box for testing.

        vagrant basebox export CentOS-6.3-x86_64-minimal

That’s it, the VM is ready to use with vagrant.


credits
=======

        https://github.com/ripienaar/gdash
        http://graphite.wikidot.com/
        https://github.com/etsy/statsd
        https://github.com/jedi4ever/veewee
        http://vagrantup.com/
        http://www.centos.org/


license 
========

MIT License

Copyright (c) 2012 Damian ONeill

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.