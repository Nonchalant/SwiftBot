.PHONY: build, stop, run

build:
	docker build -t nonchalant/swiftbot:4.1 \
		--build-arg SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN} \
		--build-arg MEMBER_ID=${MEMBER_ID} \
		.

run: stop
	docker-compose up -d

stop:
	docker-compose down
