docker build -t openkm:6.7.1 .
docker tag openkm:6.7 172.18.0.2/yachay/openkm:6.7.1
docker push 172.18.0.2/yachay/openkm:6.7.1

docker rmi 172.18.0.2/yachay/openkm:6.7.1
docker rmi openkm:6.7.1
