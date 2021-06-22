# aws-ami-create

## Preconditions
* Install [Homebrew](https://brew.sh/index_ja.html)
* ruby 2.4.0 or more
    * use `rbenv` (recommend)
* bundler
    * execute `bundle update` (recommend)

## Installation

* install packer

```
brew install packer
packer --version
> 1.0.0
```

* install aws-cli

```
brew install awscli
aws --version
> aws-cli/1.11.100 Python/2.7.6 Darwin/14.4.0 botocore/1.5.63
```

* install ansible

```
brew install ansible
ansible --version
> ansible 2.3.1.0
```

## Execution

### Execute locally

* initialize vagrant

```
make init-vagrant
```

if error was occured, run the command below.

`vagrant vbguest && vagrant up && vagrant sandbox on`

### Execute on server

* get environment key-pair

```
make get-keypair ENV=dev
```

* create AMI for nlp batch

```
make create-ami ENV=dev TARGET=deploy
```
