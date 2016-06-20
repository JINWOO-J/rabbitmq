REPO = dr.ytlabs.co.kr
REPO_HUB = jinwoo
NAME = rabbitmq
VERSION = 3.6.2
include ENVAR

GIT_TAG = $(shell git describe --abbrev=0 --match "$(VERSION)")

.PHONY: all build push test tag_latest release ssh

all: build

build:
	cat .Dockerfile | sed  "s/__RS_VERSION__/$(VERSION)/g"   > Dockerfile
	docker build --no-cache --rm=true --build-arg RS_VERSION=$(VERSION) -t $(NAME):$(VERSION) .

push:
	docker tag -f $(NAME):$(VERSION) $(REPO)/$(NAME):$(VERSION)
	docker push $(REPO)/$(NAME):$(VERSION)
	
push_hub:
	docker tag -f $(NAME):$(VERSION) $(REPO_HUB)/$(NAME):$(VERSION)
	docker push $(REPO_HUB)/$(NAME):$(VERSION)

build_hub:
ifeq "$(GIT_TAG)" "$(VERSION)"
	git add .
	git commit -m "$(NAME):$(VERSION) by Makefile"
	echo "DELETE TAG $(VERSION)"
	git tag -d $(VERSION)
	git push origin :tags/$(VERSION)		
else 
	echo "Make TAG $(VERSION)"
endif

	echo "TRIGGER_KEY" ${TRIGGERKEY}
	cat .Dockerfile | sed  "s/__RS_VERSION__/$(VERSION)/g"   > Dockerfile

	git tag -a "$(VERSION)" -m "$(VERSION) by Makefile"
	git push origin --tags
	curl -H "Content-Type: application/json" --data '{"source_type": "Tag", "source_name": "$(VERSION)"}' -X POST https://registry.hub.docker.com/u/jinwoo/${NAME}/trigger/${TRIGGERKEY}/

tag_hub:
	curl -H "Content-Type: application/json" --data '{"source_type": "Tag", "source_name": "$(VERSION)"}' -X POST https://registry.hub.docker.com/u/jinwoo/${NAME}/trigger/${TRIGGERKEY}/


bash: 
	docker run --entrypoint="bash" --rm -it $(NAME):$(VERSION)  

tag_latest:
	docker tag -f $(REPO)/$(NAME):$(VERSION) $(REPO)/$(NAME):latest
	docker push $(REPO)/$(NAME):latest
	
init:
	git init
	git add .
	git commit -m "first commit"
	git remote add origin git@github.com:JINWOO-J/$(NAME).git
	git push -u origin master	
