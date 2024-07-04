SHELL := /bin/bash

PWD = $(shell pwd)
MINIO_DIR = minio
MINIO_ENV_FILE = .env
MINIO_DEFAULT_ENV_FILE = default.env
MINIO_CREDENTIALS_FILE = credentials.json

TERRAFORM_DIR = terraform
TERRAFORM_KIND_CLUSTER_DIR = $(TERRAFORM_DIR)/kind-cluster
TERRAFORM_OBSERVABILITY_DIR = $(TERRAFORM_DIR)/observability

TF_PLAN_FILE = terraform.tfplan

.PHONY: minio-up
minio-up:
	@cd $(MINIO_DIR); if [[ -f $(MINIO_ENV_FILE) ]]; then \
		echo "Using custom environment variables"; \
		source $(MINIO_ENV_FILE) && envsubst < docker-compose.yaml | docker-compose -f - up -d; \
	else \
		echo "Using default environment variables"; \
		source $(MINIO_DEFAULT_ENV_FILE) && envsubst < docker-compose.yaml | docker-compose -f - up -d; \
	fi

.PHONY: minio-down
minio-down:
	cd $(MINIO_DIR); docker-compose down


.PHONY: init
init:
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-init, $(TERRAFORM_KIND_CLUSTER_DIR), $(ARGS)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-init, $(TERRAFORM_OBSERVABILITY_DIR), $(ARGS)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs)."; \
	fi

.PHONY: plan
plan:
	@if [[ $(STACK) == "kind" ]]; then \
		$(call cp-minio-creds, $(TERRAFORM_KIND_CLUSTER_DIR)); \
		$(call terraform-plan, $(TERRAFORM_KIND_CLUSTER_DIR), $(ARGS)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call cp-minio-creds, $(TERRAFORM_OBSERVABILITY_DIR)); \
		$(call terraform-plan, $(TERRAFORM_OBSERVABILITY_DIR), $(ARGS)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs)."; \
	fi

.PHONY: apply
apply:
	@if [[ $(STACK) == "kind" ]]; then \
		$(call terraform-apply, $(TERRAFORM_KIND_CLUSTER_DIR)); \
	elif [[ $(STACK) == "observability" || $(STACK) == "obs" ]]; then \
		$(call terraform-apply, $(TERRAFORM_OBSERVABILITY_DIR)); \
	else \
		echo "Invalid STACK value. Must be one of kind, observability (abbr. obs)."; \
	fi


define cp-minio-creds
	cp $(MINIO_DIR)/$(MINIO_CREDENTIALS_FILE) $(1)/$(MINIO_CREDENTIALS_FILE)
endef

define terraform-validate
	cd $(1); terraform validate
endef

define terraform-fmt
	cd $(1); terraform fmt -recursive
endef

define terraform-init
	cd $(1); terraform init $(2)
endef

define terraform-plan
	cd $(1); terraform plan -out=$(TF_PLAN_FILE) $(2)
endef

define terraform-apply
	cd $(1); terraform apply $(TF_PLAN_FILE)
endef
