.PHONY:

# ==============================================================================
# Docker

develop:
	echo "Starting develop docker compose"
	docker-compose -f docker-compose.yml up --build -d

local:
	echo "Starting local docker compose"
	docker-compose -f docker-compose.local.yml up --build

crate_topics:
	docker exec -it kafka1 kafka-topics --zookeeper zookeeper:2181 --create --topic create-product --partitions 3 --replication-factor 2
	docker exec -it kafka1 kafka-topics --zookeeper zookeeper:2181 --create --topic update-product --partitions 3 --replication-factor 2
	docker exec -it kafka1 kafka-topics --zookeeper zookeeper:2181 --create --topic dead-letter-queue --partitions 3 --replication-factor 2


# ==============================================================================
# Modules support

deps-reset:
	git checkout -- go.mod
	go mod tidy
	go mod vendor

tidy:
	go mod tidy
	go mod vendor

deps-upgrade:
	# go get $(go list -f '{{if not (or .Main .Indirect)}}{{.Path}}{{end}}' -m all)
	go get -u -t -d -v ./...
	go mod tidy
	go mod vendor

deps-cleancache:
	go clean -modcache

# ==============================================================================
# Linters

run-linter:
	echo "Starting linters"
	golangci-lint run ./...


# ==============================================================================
# Docker support

FILES := $(shell docker ps -aq)

down-local:
	docker stop $(FILES)
	docker rm $(FILES)

clean:
	docker system prune -f

logs-local:
	docker logs -f $(FILES)


# ==============================================================================
# Make local SSL Certificate

cert:
	echo "Generating SSL certificates"
	cd ./ssl && sh instructions.sh


# ==============================================================================
# Swagger

swagger:
	echo "Starting swagger generating"
	swag init -g **/**/*.go

# ==============================================================================
# MongoDB

mongo:
	cd ./scripts && mongo admin -u admin -p admin < init.js