## Build and Run
    docker build --rm -t mattcho/centos7-php7-oci8 .

    docker run -tid -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $HOME/Code/datahub:/var/www/app --cap-add SYS_ADMIN -p 8080:80 --name hub mattcho/centos7-php7-oci8

## Useful Docker commands
    docker exec -it hub /bin/bash
    docker rmi $(docker images -a -q)
    docker rm $(docker ps -a -q)