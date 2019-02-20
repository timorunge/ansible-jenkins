# jenkins

This role installs and configures [Jenkins](https://jenkins.io/) - the
leading open source automation server.

## Requirements

This role requires
[Ansible 2.7.0](https://docs.ansible.com/ansible/devel/roadmap/ROADMAP_2_7.html)
or higher (the module is relaying on `access_time` and `modification_time_format` in
the `file_module`).

You can simply use pip to install (and define) a stable version:

```sh
pip install ansible==2.7.7
```

All platform requirements are listed in the metadata file.

## Install

```sh
ansible-galaxy install timorunge.jenkins
```

## Role Variables

The variables that can be passed to this role. For all variables, take
a look at [defaults/main.yml](defaults/main.yml).

```yaml
# Installation

# If `jenkins_use_official_repo` is set to `true` the module will use the
# jenkins.io repository for the installation of Jenkins. If set to `false`
# the module will download the defined `jenkins_version` as a package from
# jenkins.io and install the same.

# Use the official LTS Jenkins repository.
# Type: Bool
jenkins_use_official_repo: true

# The Jenkins version which should be installed if not using the repository.
# Please keep in mind that the version naming differs if you're using TLS
# or not.
# An overview of available versions can be found on the Jenkins downloads
# page: https://jenkins.io/download/
# Type: Str
# jenkins_version: 2.150.3 # TLS
# jenkins_version: 2.165   # Weekly
jenkins_version: 2.150.3

# Configuration

# The Jenkins user and group.
# Type: Str
jenkins_user: jenkins
jenkins_group: "{{ jenkins_user }}"

# The home of Jenkins.
# Don't forget to change the `JENKINS_HOME` in the `jenkins_environment`.
# If Jenkins is already up and running you should stop it before.
# Type: Str
jenkins_home: "/var/lib/{{ jenkins_user }}"

# Enable / disable Jenkins as a service.
# Type: Bool
jenkins_service_enabled: true

# Configure the Jenkins environment using /etc/defaults/jenkins for debian
# based systems and /etc/sysconfig/jenkins for RedHat based systems.
# Values are getting quoted automatically.
# Type: Dict
# Example (Debian based system):
# jenkins_environment:
#   NAME: "{{ jenkins_user }}"
#   JAVA_ARGS: "-Djava.awt.headless=true"
#   PIDFILE: /var/run/$NAME/$NAME.pid
#   JENKINS_USER: $NAME
#   JENKINS_GROUP: $NAME
#   JENKINS_WAR: /usr/share/$NAME/$NAME.war
#   JENKINS_HOME: "/var/lib/$NAME"
#   RUN_STANDALONE: true
#   JENKINS_LOG: /var/log/$NAME/$NAME.log
#   JENKINS_ENABLE_ACCESS_LOG: '"no"'
#   MAXOPENFILES: 8192
#   HTTP_PORT: 8080
#   PREFIX: $NAME
#   JENKINS_ARGS: "--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT"
jenkins_environment: {}
```

### Default Jenkins environment variables

#### Debian based

```sh
NAME=jenkins
JAVA_ARGS="-Djava.awt.headless=true"
PIDFILE=/var/run/$NAME/$NAME.pid
JENKINS_USER=$NAME
JENKINS_GROUP=$NAME
JENKINS_WAR=/usr/share/$NAME/$NAME.war
JENKINS_HOME="/var/lib/$NAME"
RUN_STANDALONE=true
JENKINS_LOG=/var/log/$NAME/$NAME.log
JENKINS_ENABLE_ACCESS_LOG="no"
MAXOPENFILES=8192
HTTP_PORT=8080
PREFIX=$NAME
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT"
```

#### RedHat based

```sh
JENKINS_HOME="/var/lib/jenkins"
JENKINS_JAVA_CMD=""
JENKINS_USER="jenkins"
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"
JENKINS_PORT="8080"
JENKINS_LISTEN_ADDRESS=""
JENKINS_HTTPS_PORT=""
JENKINS_HTTPS_KEYSTORE=""
JENKINS_HTTPS_KEYSTORE_PASSWORD=""
JENKINS_HTTPS_LISTEN_ADDRESS=""
JENKINS_DEBUG_LEVEL="5"
JENKINS_ENABLE_ACCESS_LOG="no"
JENKINS_HANDLER_MAX="100"
JENKINS_HANDLER_IDLE="20"
JENKINS_ARGS=""
```

## Examples

All examples are assuming that you're using a Debian based operating system.
For RedHat based systems the key value pairs in `jenkins_environment` differ.

### 1) Full configuration example

Here you can see a full example of a Jenkins server. In this case the role
will download the `2.150.3` LTS package directly and not use the
repository (`jenkins_use_official_repo` is set to `false`).

Beside that we're changing the `HTTP_PORT` to port `8000` and increasing the
`MAXOPENFILES` to `16384`.

This is basically the [test.yml](tests/test.yml) file which is used for
testing.

```yaml
- hosts: jenkins
  gather_facts: true
  vars:
    jenkins_use_official_repo: false
    jenkins_version: 2.150.3
    jenkins_user: jenkins
    jenkins_group: "{{ jenkins_user }}"
    jenkins_home: "/var/lib/{{ jenkins_user }}"
    jenkins_service_enabled: true
    jenkins_environment:
      HTTP_PORT: 8000
      MAXOPENFILES: 16384
  roles:
    - timorunge.jenkins
```

### 2) Installation from the official repository

Use the Jenkins repository (`jenkins_use_official_repo` is set to `true`).

```yaml
- hosts: jenkins
  vars:
    jenkins_use_official_repo: true
    jenkins_service_enabled: true
    ...
```

### 3) Installation from deb or rpm package

You can install Jenkins directly from a
[GitHub release](https://jenkins.io/download/). Just define the
`jenkins_version` and set `jenkins_use_official_repo` to `false`.

```yaml
- hosts: jenkins
  vars:
    jenkins_use_official_repo: false
    jenkins_version: 2.150.3
    jenkins_user: jenkins
    ...
```

### 4) Configure the Jenkins environment

You can configure the Jenkins environmnt variables located in
`/etc/defaults/jenkins` easily via `jenkins_environment`.

Jenkins is restarting after a configuration change.

```yaml
- hosts: jenkins
  gather_facts: true
  vars:
    jenkins_use_official_repo: false
    jenkins_version: 2.150.3
    jenkins_environment:
      HTTP_PORT: 8000
      MAXOPENFILES: 16384
    ...
```

## Known issues or: Good to know

### 1) Jenkins > 2.46.3 on Debian 8 and Ubuntu 14.04

Jenkins `2.46.3` is the latest LTS version which is running with `Java 7`.
Newer versions require `Java 8`. Debian 8 and Ubuntu 14.04 are not providing
packages for `Java 7`.

## Testing

[![Build Status](https://travis-ci.org/timorunge/ansible-jenkins.svg?branch=master)](https://travis-ci.org/timorunge/ansible-jenkins)

Tests are done with [Docker](https://www.docker.com) and
[docker_test_runner](https://github.com/timorunge/docker-test-runner) which
brings up the following containers with different environment settings:

- CentOS 7
- Debian 8.10 (Jessie)
- Debian 9.4 (Stretch)
- Ubuntu 14.04 (Trusty Tahr)
- Ubuntu 16.04 (Xenial Xerus)
- Ubuntu 17.10 (Artful Aardvark)
- Ubuntu 18.04 (Bionic Beaver)
- Ubuntu 18.10 (Cosmic Cuttlefish)

Ansible 2.7.7 is installed on all containers and a
[test playbook](tests/test.yml) is getting applied.

For further details and additional checks take a look at the
[docker_test_runner configuration](tests/docker_test_runner.yml) and the
[Docker entrypoint](tests/docker/docker-entrypoint.sh).
An high level overview can be found in the following table:

| Distribution | Version | Official repository | Package |
|--------------|---------|---------------------|---------|
| CentOS       | 7       | yes                 | 2.150.3 |
| Debian       | 8.10    | no                  | 2.46.3  |
| Debian       | 9.4     | yes                 | 2.150.3 |
| Ubuntu       | 14.04   | no                  | 2.46.3  |
| Ubuntu       | 16.04   | yes                 | 2.150.3 |
| Ubuntu       | 17.10   | yes                 | 2.150.3 |
| Ubuntu       | 18.04   | yes                 | 2.150.3 |
| Ubuntu       | 18.10   | yes                 | 2.150.3 |

```sh
# Testing locally:
curl https://raw.githubusercontent.com/timorunge/docker-test-runner/master/install.sh | sh
./docker_test_runner.py -f tests/docker_test_runner.yml
```

Since the build time on Travis is limited for public repositories the
automated tests are limited to:

- CentOS 7
- Debian 8.10 (Jessie)
- Debian 9.4 (Stretch)
- Ubuntu 16.04 (Xenial Xerus)
- Ubuntu 18.04 (Bionic Beaver)

## Dependencies

None

## License

[BSD 3-Clause "New" or "Revised" License](LICENSE)

## Author Information

- Timo Runge
