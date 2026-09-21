#!/bin/bash

docker stop ex10-nginx || true
docker rm ex10-nginx || true

exit 0