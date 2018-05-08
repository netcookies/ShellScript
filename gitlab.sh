#/bin/bash -vx

#Desired version, unless one provided as argument
VERSION=${1:-'8.17.3-ce.0'}
#VERSION='8.13.0-ce.0'
#VERSION='latest'

echo "Going to use: gitlab/gitlab-ce:${VERSION} "

docker pull gitlab/gitlab-ce:${VERSION}
docker stop gitlab
docker rm gitlab

#This is req. in case you use SELinux:
chcon -Rt svirt_sandbox_file_t /storage/srv/gitlab/ || true
#/proc/sys/fs/file-max #this is shared with the host
GITLAB_FILEMAX=1000000
[[ $(cat /proc/sys/fs/file-max) -lt ${GITLAB_FILEMAX} ]] && echo $GITLAB_FILEMAX > /proc/sys/fs/file-max

# https://gitlab.com/gitlab-org/omnibus-gitlab/issues/1217 #mattermost docker containers
# # --sysctl vm.overcommit_memory=1 \
docker run --detach --name gitlab \
 --hostname gitlab.corp.dontbeevil.com \
 --sysctl net.core.somaxconn=1024 \
 --ulimit sigpending=62793 \
 --ulimit nproc=131072 \
 --ulimit nofile=60000 \
 --ulimit core=0 \
 --publish 443:443 --publish 80:80 --publish 22:22 --publish 8060:8060 \
 --restart always \
 --env GITLAB_OMNIBUS_CONFIG="external_url 'https://gitlab.corp.dontbeevil.com/'; gitlab_rails['lfs_enabled'] = true; mattermost_external_url 'http://mattermost.corp.dontbeevil.com';" \
 --volume /storage/srv/gitlab/config:/etc/gitlab:z \
 --volume /storage/srv/gitlab/logs:/var/log/gitlab:z \
 --volume /storage/srv/gitlab/data:/var/opt/gitlab:z \
 --volume /etc/localtime:/etc/localtime \
 gitlab/gitlab-ce:${VERSION}

# --privileged is required in order to set proper ulimits somaxconn, fs.file-max, etc; from all these, only file-max influences host, rest are only at cont. level.
# --ulimit sigpending=62793 --ulimit nproc=131072
# we cannot mount /proc/sys/net/core/somaxconn inside container (docker error:  cannot be mounted because it is located inside "/proc" )
# none of of capabilites help. We tried: docker run --ulimit sigpending=62793 --ulimit nproc=131072 --cap-add=CHOWN --cap-add=DAC_OVERRIDE --cap-add=FSETID --cap-add=FOWNER --cap-add=MKNOD --cap-add=NET_RAW --cap-add=SETGID --cap-add=SETUID --cap-add=SETFCAP --cap-add=SETPCAP --cap-add=NET_BIND_SERVICE --cap-add=SYS_CHROOT --cap-add=KILL --cap-add=AUDIT_WRITE gitlab/gitlab-ce

# To remove --privileged we need docker 1.12+ where we can set sysctl parameters on docker run, like we can ulimit parameters now. Till then, we need --privileged.

echo -e "waiting for services to start before checking status. So: sleeping 60 sec. \nFor startup status, if you want, you may want to ctrl+x and run: 'docker logs -f gitlab' or 'docker exec gitlab gitlab-ctl status' yourself."
sleep 60
docker exec gitlab gitlab-ctl status
