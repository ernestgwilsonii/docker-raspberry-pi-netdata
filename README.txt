######################################################
# netdata - Real-time Linux monitoring dashboards    #
#           (in a Docker container) for Raspberry Pi #
#                         REF: http://netdata.cloud/ #
#                    REF: https://docs.netdata.cloud #
######################################################


###############################################################################
# Prerequisites
###############
ssh pi@YourPiIPAddressHere
sudo -u root bash
apt-get update && apt-get dist-upgrade -y
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
pip install --upgrade docker-compose
docker swarm init
###############################################################################


###############################################################################
# Quick (if using Docker Swarm and bind mounted data in /opt)
sudo -u root bash
mkdir -p /opt/docker-compose
cd /opt/docker-compose
git clone https://github.com/ernestgwilsonii/docker-raspberry-pi-netdata.git
cd docker-raspberry-pi-netdata
./lazy.sh
#rm -Rf /opt/netdata
docker stack deploy -c docker-compose.yml netdata-stack
docker stack ls
docker service ls
docker ps
# http://YourPiIPAddressHere:8888
#docker stack rm netdata-stack
#rm -Rf /opt/netdata
#docker system prune -af
###############################################################################


###############################################################################
# Docker Images
sudo bash
time docker pull netdata/netdata:v1.13.0-armhf   # REF: https://hub.docker.com/r/netdata/netdata
docker images

# Since this cannot be used in a Docker Swarm (at this time) use Docker run instead
docker run -d --name=netdata \
  -p 19999:19999 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  --restart always \
  netdata/netdata:v1.15.0-armhf

docker ps
# Test: http://YourPiIPAddressHere:19999

# Genenerate a sample config
curl -s -o netdata.conf.example "http://localhost:19999/netdata.conf"

docker stop netdata
docker rm netdata
###############################################################################


###############################################################################
# First time setup #
####################
# Create bind mounted directories

# netdata
# REF: https://hub.docker.com/r/netdata/netdata
# REF: https://docs.netdata.cloud/backends/
sudo -u root bash
mkdir -p /opt/netdata/etc/netdata
cp -n netdata.conf /opt/netdata/etc/netdata/netdata.conf
touch /opt/netdata/etc/netdata/.opt-out-from-anonymous-statistics
hostname -I | awk '{print "destination="$1":2003"}' >.env
hostname -I | awk '{print "registry=http://"$1":1999"}' >>.env
chmod -R a+rw /opt/netdata
###############################################################################


###############################################################################
# Deploy #
##########

# Swarm mode currently not supported for cap_add - https://github.com/moby/moby/pull/38380
# Can still use docker-compose.yml without Swarm mode:
sudo -u root bash
cd /opt/docker-compose/docker-raspberry-pi-netdata
docker-compose up
docker-compose up -d
docker ps
docker-compose down

# Use systemctl to start docker-compose-netdata as a work-around
cp /opt/docker-compose/docker-raspberry-pi-netdata/docker-compose-netdata.service /etc/systemd/system/docker-compose-netdata.service
systemctl enable docker-compose-netdata
systemctl start docker-compose-netdata



# FUTURE:
# Deploy the stack into a Docker Swarm
#sudo -u root bash
#docker stack deploy -c docker-compose.yml netdata-stack
#docker stack rm netdata-stack

# Verify
#sudo -u root bash
#docker stack ls
#docker service ls | grep netdata-stack
#docker service logs -f netdata-stack_netdata
#docker ps
###############################################################################
