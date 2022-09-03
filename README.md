# docker-dev

local development container based on Ubuntu

## How to use
1. Clone repo and cd into root dir
2. Run `docker build -t <tag-name> .` to build the image
3. Run `docker-compose up -d ` to start the container
4. Run `docker exec -it <container-name> bash` to exec into container
5. Run `docker-compose down` to shut down the container

## Optional
You can also opt to add aliases that will allow you to start or shut down the container from anywhere

Add the following lines of code to `~/.bash_profile` or `~/.zshrc`

```bash
function updc() { current_dir=$PWD; cd ~/workspace/docker-dev; docker-compose up -d; cd $current_dir; }
function downdc() { current_dir=$PWD; cd ~/workspace/docker-dev; docker-compose down; cd $current_dir; }
function dintoc() { docker exec -it <container-name> bash; }
```

## Known Issues
1. Turn off VPN before building this image.
2. On windows with WSL2, you may need to run `docker exec -it <container-name> bash;` with a winpty prefix like this: `winpty docker exec -it <container-name> bash;`
3. Building this image on M1 Apple Silicon leads to some issues: https://github.com/ibrahiem96/docker-dev/issues/1#issue-1331092427
