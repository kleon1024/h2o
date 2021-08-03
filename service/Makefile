.PHONY: run-server

# Go Flags
GOFLAGS ?= $(GOFLAGS:)
# We need to export GOBIN to allow it to be set
# for processes spawned from the Makefile
export GOBIN ?= $(PWD)/bin
GO=go

GO_MAJOR_VERSION = $(shell $(GO) version | cut -c 14- | cut -d' ' -f1 | cut -d'.' -f1)
GO_MINOR_VERSION = $(shell $(GO) version | cut -c 14- | cut -d' ' -f1 | cut -d'.' -f2)
MINIMUM_SUPPORTED_GO_MAJOR_VERSION = 1
MINIMUM_SUPPORTED_GO_MINOR_VERSION = 15
GO_VERSION_VALIDATION_ERR_MSG = Golang version is not supported, please update to at least $(MINIMUM_SUPPORTED_GO_MAJOR_VERSION).$(MINIMUM_SUPPORTED_GO_MINOR_VERSION)

# GOOS/GOARCH of the build host, used to determine whether we're cross-compiling or not
BUILDER_GOOS_GOARCH="$(shell $(GO) env GOOS)_$(shell $(GO) env GOARCH)"

PLATFORM_FILES="./cmd/mattermost/main.go"

# Output paths
DIST_ROOT=dist
DIST_PATH=$(DIST_ROOT)/mattermost
DIST_PATH_LIN=$(DIST_ROOT)/linux/mattermost
DIST_PATH_OSX=$(DIST_ROOT)/osx/mattermost
DIST_PATH_WIN=$(DIST_ROOT)/windows/mattermost


LDFLAGS += -X "github.com/mattermost/mattermost-server/v6/model.MockCWS=$(MM_ENABLE_CWS_MOCK)"

RUN_IN_BACKGROUND ?=
ifeq ($(RUN_SERVER_IN_BACKGROUND),true)
	RUN_IN_BACKGROUND := &
endif

start-docker-check:
ifeq (,$(findstring minio,$(ENABLED_DOCKER_SERVICES)))
  TEMP_DOCKER_SERVICES:=$(TEMP_DOCKER_SERVICES) minio
endif
ifeq ($(BUILD_ENTERPRISE_READY),true)
  ifeq (,$(findstring openldap,$(ENABLED_DOCKER_SERVICES)))
    TEMP_DOCKER_SERVICES:=$(TEMP_DOCKER_SERVICES) openldap
  endif
  ifeq (,$(findstring elasticsearch,$(ENABLED_DOCKER_SERVICES)))
    TEMP_DOCKER_SERVICES:=$(TEMP_DOCKER_SERVICES) elasticsearch
  endif
endif
ENABLED_DOCKER_SERVICES:=$(ENABLED_DOCKER_SERVICES) $(TEMP_DOCKER_SERVICES)

start-docker:
ifneq ($(IS_CI),false)
	@echo CI Build: skipping docker start
else ifeq ($(MM_NO_DOCKER),true)
	@echo No Docker Enabled: skipping docker start
else
	@echo Starting docker containers

	$(GO) run ./build/docker-compose-generator/main.go $(ENABLED_DOCKER_SERVICES) | docker-compose -f docker-compose.makefile.yml -f /dev/stdin run --rm start_dependencies

validate-go-version: ## Validates the installed version of go against H2O's minimum requirement.
	@if [ $(GO_MAJOR_VERSION) -gt $(MINIMUM_SUPPORTED_GO_MAJOR_VERSION) ]; then \
		exit 0 ;\
	elif [ $(GO_MAJOR_VERSION) -lt $(MINIMUM_SUPPORTED_GO_MAJOR_VERSION) ]; then \
		echo '$(GO_VERSION_VALIDATION_ERR_MSG)';\
		exit 1; \
	elif [ $(GO_MINOR_VERSION) -lt $(MINIMUM_SUPPORTED_GO_MINOR_VERSION) ] ; then \
		echo '$(GO_VERSION_VALIDATION_ERR_MSG)';\
		exit 1; \
	fi

run-server: validate-go-version start-docker ## Starts the server.
	@echo Running h2o for development

	$(GO) run $(GOFLAGS) -ldflags '$(LDFLAGS)' $(PLATFORM_FILES) 2>&1 | \
	    $(GO) run $(GOFLAGS) -ldflags '$(LDFLAGS)' $(PLATFORM_FILES) logs --logrus $(RUN_IN_BACKGROUND)

stop-docker: ## Stops the docker containers for local development.
ifeq ($(MM_NO_DOCKER),true)
	@echo No Docker Enabled: skipping docker stop
else
	@echo Stopping docker containers

	docker-compose stop
endif

clean-docker: ## Deletes the docker containers for local development.
ifeq ($(MM_NO_DOCKER),true)
	@echo No Docker Enabled: skipping docker clean
else
	@echo Removing docker containers

	docker-compose down -v
	docker-compose rm -v
endif

stop-server: ## Stops the server.
	@echo Stopping h2o

ifeq ($(BUILDER_GOOS_GOARCH),"windows_amd64")
	wmic process where "Caption='go.exe' and CommandLine like '%go.exe run%'" call terminate
	wmic process where "Caption='h2o.exe' and CommandLine like '%go-build%'" call terminate
else
	@for PID in $$(ps -ef | grep "[g]o run" | awk '{ print $$2 }'); do \
		echo stopping go $$PID; \
		kill $$PID; \
	done
	@for PID in $$(ps -ef | grep "[g]o-build" | awk '{ print $$2 }'); do \
		echo stopping h2o $$PID; \
		kill $$PID; \
	done
endif