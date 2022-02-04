# docker-dev

local development container based on Ubuntu

## How to use

<strong>Turn off VPN before building this image</strong>

1. Clone repo and cd into root dir
2. Run `docker build -t <tag-name> .` to build the image
3. Run `docker-compose up -d ` to start the container
4. Run `docker exec -it docker-dev-workspace-1 bash` to exec into container
5. Run `docker-compose down` to shut down the container
