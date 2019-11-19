#!/bin/sh

xrpcgen-0.9.0 --gen java calc.thrift

cp gen-java/* ../src/ -rf
rm gen-java -rf

