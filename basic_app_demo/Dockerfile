FROM openjdk:8
MAINTAINER Chungnt<chungnt@vng.com.vn>
COPY . /usr/src/docker/basic_app_demo
WORKDIR /usr/src/docker/basic_app_demo
RUN javac HelloDocker.java
CMD ["java", "HelloDocker"]