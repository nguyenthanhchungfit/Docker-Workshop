docker image build -t app-client .
docker container run --name app-client -d app-client




docker container run --network server-client-conn --name app-client -d app-client