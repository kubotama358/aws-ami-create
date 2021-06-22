ENV = $1
TARGET = $2
CD = cd packer/
REGION = ap-northeast-1
PROFILE = ${ENV}
AWS = $(shell ls -a ~/ | grep .aws)
PACKER_KEY_LOCATION = s3://${ENV}-packer-keypair-bucket/${REGION}/
PACKER_KEY_NAME = ${ENV}_packer_keypair.pem

get-keypair:
ifeq ($(AWS),.aws)
	aws s3 cp ${PACKER_KEY_LOCATION}${PACKER_KEY_NAME} . --profile ${PROFILE}
else
	aws s3 cp ${PACKER_KEY_LOCATION}${PACKER_KEY_NAME} .
endif

validate:
ifeq ($(AWS),.aws)
	@${CD} && \
		packer validate \
		-var-file=env-${ENV}-variables.json \
		-var-file=role-${TARGET}-variables.json \
		-var 'aws_key_file=$(CURDIR)/${PACKER_KEY_NAME}' \
		-var 'aws_profile=${PROFILE}' \
		ami-template.json
else
	@${CD} && \
		packer validate \
		-var-file=env-${ENV}-variables.json \
		-var-file=role-${TARGET}-variables.json \
		-var 'aws_key_file=$(CURDIR)/${PACKER_KEY_NAME}' \
		ami-template-deploy.json
endif

create-ami:
ifeq ($(AWS),.aws)
	@${CD} && \
		env AWS_PROFILE=${PROFILE} packer build \
		-var-file=env-${ENV}-variables.json \
		-var-file=role-${TARGET}-variables.json \
		-on-error=ask \
		-var 'aws_key_file=$(CURDIR)/${PACKER_KEY_NAME}' \
		-var 'aws_profile=${PROFILE}' \
		ami-template.json
else
	@${CD} && \
		packer build \
		-var-file=env-${ENV}-variables.json \
		-var-file=role-${TARGET}-variables.json \
		-on-error=ask \
		-var 'aws_key_file=$(CURDIR)/${PACKER_KEY_NAME}' \
		ami-template-deploy.json
endif

init-vagrant:
	vagrant halt && vagrant destroy -f && vagrant up --provision && vagrant sandbox on

test-local:
	@${CD} && \
		packer build -var-file=env-local-variables.json \
		-on-error=ask \
		-var-file=role-${TARGET}-variables.json \
		-var 'ssh_key=$(CURDIR)/.vagrant/machines/default/virtualbox/private_key' \
		ami-local-template.json && \
		vagrant sandbox rollback
