#!/bin/bash

set -e

dnf update -y

dnf install -y \
  ruby \
  wget \
  docker

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

cd /tmp

wget https://aws-codedeploy-ap-northeast-1.s3.ap-northeast-1.amazonaws.com/latest/install

chmod +x ./install

./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent
