# standard info
PROJECT = ghost 
REGISTRY = registry.giantswarm.io
USERNAME :=  $(shell swarm user)

# AWS auth and bucket info 
BACKUPS_ENABLED=false
AWS_ACCESS_KEY_ID=AKIAIWC5LPPK3PYWKBLQ
AWS_SECRET_ACCESS_KEY=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
AWS_DEFAULT_REGION=eu-central-1
S3_BUCKET=giantghost-kord/backups

# mysql stuff
MYSQL_USERNAME=root
MYSQL_PASSWORD=f00bar

# ghost stuff
MYSQL_DATABASE=ghost
DOMAIN=ghost-$(USERNAME).gigantic.io

docker-build:
	docker build -t $(REGISTRY)/$(USERNAME)/$(PROJECT) .

docker-run:
	docker run --rm -ti \
		-e "BACKUPS_ENABLED=$(BACKUPS_ENABLED)" \
		-e "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
		-e "AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)" \
		-e "AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION)" \
		-e "S3_BUCKET=$(S3_BUCKET)" \
		-e "DOMAIN=$(DOMAIN)" \
		-e "MYSQL_DATABASE=$(MYSQL_DATABASE)" \
		-e "MYSQL_USERNAME=$(MYSQL_USERNAME)" \
		-e "MYSQL_PASSWORD=$(MYSQL_PASSWORD)" \
		-e "PATH_DATEPATTERN=%Y/%m" \
		--link mysql:mysql \
		-p 80:2368 \
		$(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-mysql:
	docker run -d --name=mysql \
		-e "MYSQL_ROOT_PASSWORD=$(MYSQL_PASSWORD)" \
		-e "MYSQL_DATABASE=$(MYSQL_DATABASE)" \
		mysql:5.5

docker-push: docker-build
	docker push $(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-pull:
	docker pull $(REGISTRY)/$(USERNAME)/$(PROJECT)

swarm-up: docker-push
	swarm up \
	  --var=mysqldatabase=$(MYSQL_DATABASE) \
	  --var=mysqlpassword=$(MYSQL_PASSWORD) \
	  --var=mysqlusername=$(MYSQL_USERNAME) \
	  --var=domain=$(DOMAIN) \
	  --var=backupsenabled=$(BACKUPS_ENABLED) \
	  --var=awskey=$(AWS_ACCESS_KEY_ID) \
	  --var=awssecret=$(AWS_SECRET_ACCESS_KEY) \
	  --var=awsregion=$(AWS_DEFAULT_REGION) \
	  --var=s3bucket=$(S3_BUCKET) \
	  --var=username=$(USERNAME)
	@echo "Visit http://$(DOMAIN) to see your blog and http://$(DOMAIN)/ghost/ to set it up"
