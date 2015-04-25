# standard info
PROJECT = ghost-varnish
REGISTRY = registry.giantswarm.io
USERNAME := $(shell swarm user)

docker-build:
	docker build -t $(REGISTRY)/$(USERNAME)/$(PROJECT) .

docker-push: docker-build
	docker push $(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-run: docker-build
	docker run --rm -ti \
	    -e VARNISH_BACKEND_IP=192.168.59.103 \
    	-e VARNISH_BACKEND_PORT=2368 \
    	-e VARNISH_STORAGE_AMOUNT=100M \
		--link ghost:ghost \
		-p 80:80 \
		--name=ghost-varnish \
		$(REGISTRY)/$(USERNAME)/$(PROJECT)