# Automated Linux Server Setup

This project provisions a Linux server automatically.

## Features

- Installs and configures nginx
- Deploys a custom system tool (reze-fetch)
- Sets up and enables a systemd service
- Reproducible setup via single script

## Usage

```bash
git clone <repo>
cd infra-setup
sudo ./setup.sh
```


## Included Tool: reze-fetch

`reze-fetch` is a small custom system utility written in C.

It retrieves basic system information such as:

- hostname
- kernel version

In this project, it is deployed as a systemd service to demonstrate:

- custom binary deployment
- service integration into the system


## Result

After execution:

- nginx is installed and running
- reze-fetch is available system-wide
- a systemd service is installed and active
