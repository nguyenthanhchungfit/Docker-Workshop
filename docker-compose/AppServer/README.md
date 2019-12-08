docker image build -t app-server .
docker container run --name app-server -p 9000:9000 -d app-server


docker container run --network server-client-conn --name app-server -p 9000:9000 -d app-server