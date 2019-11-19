FROM openjdk:8
MAINTAINER chungnt@vng.com.vn

# ENV APP_NAME=user_management_app
# ENV MODE_RUN=development

COPY $PWD/conf /usr/src/docker/user_management_app/conf
COPY $PWD/dist /usr/src/docker/user_management_app/dist
COPY $PWD/deploy/user_management_app/cmd /usr/src/docker/user_management_app/cmd
COPY $PWD/deploy/user_management_app/scripts /usr/src/docker/user_management_app/scripts
COPY $PWD/deploy/user_management_app/runservice /usr/src/docker/user_management_app/

# COPY /zserver/java/jdk /zserver/java/jdk
# COPY /zserver/lib /zserver/lib

WORKDIR /usr/src/docker/user_management_app

EXPOSE 8090

# RUN chmod a+x /usr/src/docker/${APP_NAME}/*

ENTRYPOINT ["/usr/src/docker/user_management_app/runservice", "start", "development"]