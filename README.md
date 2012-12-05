statsd-graphite-gdash-vagrant-centos6
=====================================

A Vagrant CentOS 6 VM per-configured for gdash viewing onto graphite, includes carbon, whisper and statsd

overview
========

The project contains a workspace that allows you to create a Vagrant box based on CentOS 6 that contains all the necessary requirements to visualise a (gdash)[https://github.com/ripienaar/gdash] based (graphite)[http://graphite.wikidot.com/] solution.  The virtual machine also provides a statsd server that can be utilised by the host to push stats into graphite.  

The VM is setup with hostonly networking on 33.33.33.10 and a mountpoint created in the hosts local directory called ./dashboards that can be used to configure gdash dashboards in the VM.


installation
========

The solution assumes that you have (virtualbox)[https://www.virtualbox.org/] and (vagrant)[http://vagrantup.com/] already setup on your host machine.

Create the dashboards directory before starting.

      mkdir ./dashboards
      
      wget https://github.com/alrighttheresham/statsd-graphite-gdash-vagrant-centos6/blob/master/Vagrantfile

      vagrant box add CentOS-6.3-x86_64-minimal https://dl.dropbox.com/u/6164051/CentOS-6.3-x86_64-minimal.box 

      vagrant up 

Assuming no issues at this point the VM will be running and can be accessed with 

      vagrant ssh

This will provide console access to the VM.



license 
========

MIT 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.