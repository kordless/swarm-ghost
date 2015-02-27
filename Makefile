PROJECT = ghost 
REGISTRY = registry.giantswarm.io
USERNAME :=  $(shell swarm user)

patch-ghost-config:
	./tools/patch.sh

docker-build: patch-ghost-config
	docker build -t $(REGISTRY)/$(USERNAME)/$(PROJECT) .; rm tmp.sh

docker-run:
	docker run -p 80:2368 -ti --rm $(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-push: docker-build
	docker push $(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-pull:
	docker pull $(REGISTRY)/$(USERNAME)/$(PROJECT)

swarm-up: docker-push
	swarm up swarm.json --var=username=$(USERNAME)
