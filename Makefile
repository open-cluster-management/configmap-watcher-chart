include Configfile
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2017, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################

.PHONY: init\:
init::
	@mkdir -p variables
ifndef GITHUB_USER
	$(info GITHUB_USER not defined)
	exit -1
endif
	$(info Using GITHUB_USER=$(GITHUB_USER))
ifndef GITHUB_TOKEN
	$(info GITHUB_TOKEN not defined)
	exit -1
endif

-include $(shell curl -fso .build-harness -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw" "https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness"; echo .build-harness)
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable
STABLE_REPO_URL ?= https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
STABLE_CHARTS := $(wildcard stable/*)

.DEFAULT_GOAL=all

$(STABLE_BUILD_DIR):
	@mkdir -p $@

.PHONY: charts charts-stable $(STABLE_CHARTS) 

# Default aliases: charts, repo

charts: charts-stable

repo: repo-stable

charts-stable: $(STABLE_CHARTS)
$(STABLE_CHARTS): $(STABLE_BUILD_DIR) 
	cv lint helm $@
	mv $@/templates/tests/test01.yaml .
	helm package $@ -d $(STABLE_BUILD_DIR)
	mv test01.yaml $@/templates/tests

.PHONY: copyright-check
copyright-check:
	./build-tools/copyright-check.sh

.PHONY: repo repo-stable repo-incubating 

repo-stable: $(STABLE_CHARTS) $(STABLE_BUILD_DIR)
	helm repo index $(STABLE_BUILD_DIR) --url $(STABLE_REPO_URL)

.PHONY: all
all: repo-stable 

CHART_NAME ?= stable/ibm-cert-manager
VERSION := $(shell grep version ./$(CHART_NAME)/Chart.yaml | awk '{print $$2}')

.PHONY: build lint setup release-chart

default: build

tool:
	curl -fksSL https://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-linux-amd64.tar.gz | sudo tar --strip-components=1 -xvz -C /usr/local/bin/ linux-amd64/helm

setup:
	helm init -c

lint: setup
	helm lint $(CHART_NAME)

build: lint
	$(eval VERSION_NUMBER ?= ${VERSION})
	mv $(CHART_NAME)/templates/tests/test01.yaml $(CHART_NAME)/..
	helm package --version $(VERSION_NUMBER) $(CHART_NAME)
	mv $(CHART_NAME)/../test01.yaml $(CHART_NAME)/templates/tests

# Pushes chart to Artifactory repository.
release-chart: build
	$(eval VERSION_NUMBER ?= ${VERSION})
	$(eval NAME := $(notdir $(CHART_NAME)))
	$(eval FILE_NAME := $(NAME)-$(VERSION_NUMBER).tgz)
	$(eval URL := $(ARTIFACTORY_URL)/$(ARTIFACTORY_REPO))
	curl -H "X-JFrog-Art-Api: $(ARTIFACTORY_KEY)" -T $(FILE_NAME) $(URL)/$(FILE_NAME)
