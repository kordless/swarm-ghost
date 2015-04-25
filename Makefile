# standard info
PROJECT = ghost-server
REGISTRY = registry.giantswarm.io
USERNAME := $(shell swarm user)

# AWS auth and bucket info
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=eu-central-1
S3_BUCKET=giantghost-$(shell swarm user)/backups

# mailgun stuff
MAILGUN_USERNAME=
MAILGUN_APIKEY=

# mysql stuff
MYSQL_USERNAME=root
MYSQL_PASSWORD=f00bar
MYSQL_DATABASE=ghost

# domain settings
HOSTNAME=ghost-$(USERNAME).gigantic.io
CNAME=$(HOSTNAME)
DEV_HOSTNAME=$(shell boot2docker ip):2368
DEV_CNAME=$(DEV_HOSTNAME)

docker-build:
	docker build -t $(REGISTRY)/$(USERNAME)/$(PROJECT) .

docker-run: docker-build
	docker run --name=ghost --rm -ti \
		-e "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
		-e "AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)" \
		-e "AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION)" \
		-e "S3_BUCKET=$(S3_BUCKET)" \
		-e "MYSQL_DATABASE=$(MYSQL_DATABASE)" \
		-e "MYSQL_USERNAME=$(MYSQL_USERNAME)" \
		-e "MYSQL_PASSWORD=$(MYSQL_PASSWORD)" \
		-e "MAILGUN_USERNAME=$(MAILGUN_USERNAME)" \
		-e "MAILGUN_APIKEY=$(MAILGUN_APIKEY)" \
		-e "HOSTNAME=$(DEV_HOSTNAME)" \
		-e "CNAME=$(DEV_CNAME)" \
		--link mysql:mysql \
		-p 2368:2368 \
		$(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-mysql-run:
	docker run -d --name=mysql \
		-e "MYSQL_ROOT_PASSWORD=$(MYSQL_PASSWORD)" \
		-e "MYSQL_DATABASE=$(MYSQL_DATABASE)" \
		mysql:5.5

docker-varnish-run:
	$(MAKE) -C docker-varnish docker-run

docker-varnish-push:
	$(MAKE) -C docker-varnish docker-push

docker-push: docker-build
	docker push $(REGISTRY)/$(USERNAME)/$(PROJECT)

docker-pull:
	docker pull $(REGISTRY)/$(USERNAME)/$(PROJECT)

swarm-up: docker-varnish-push docker-push
	swarm up \
	  --var=awskey=$(AWS_ACCESS_KEY_ID) \
	  --var=awssecret=$(AWS_SECRET_ACCESS_KEY) \
	  --var=awsregion=$(AWS_DEFAULT_REGION) \
	  --var=s3bucket=$(S3_BUCKET) \
	  --var=mysqldatabase=$(MYSQL_DATABASE) \
	  --var=mysqlusername=$(MYSQL_USERNAME) \
	  --var=mysqlpassword=$(MYSQL_PASSWORD) \
	  --var=mailgunusername=$(MAILGUN_USERNAME) \
	  --var=mailgunapikey=$(MAILGUN_APIKEY) \
	  --var=hostname=$(HOSTNAME) \
	  --var=cname=$(CNAME) \
	  --var=username=$(USERNAME)
	@echo "Visit http://$(CNAME) to see your blog and http://$(CNAME)/ghost/ to set it up."

