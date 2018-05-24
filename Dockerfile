FROM ubuntu:14.04

COPY . /opt/
EXPOSE 8080

ENTRYPOINT ["/opt/go-ecs-ecr"]