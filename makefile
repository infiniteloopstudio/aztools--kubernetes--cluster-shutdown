SHELL := /bin/bash

IMAGE := infiniteloopstudio/aztools-kubernetes-clustershutdown

build:
	docker build -t ${IMAGE}:latest .