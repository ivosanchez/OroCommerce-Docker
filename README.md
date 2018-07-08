## Arc Docker Environment
Arc is a generic PHP, MYSQL, and Apache docker environment with some extra bash scripts to help you get a working 
development up quickly and easily.

### Creating a new Project
To start up a new project clone this repository and then run the command below from the base directory. You will then be
prompted to set the base project environment variables.
```
./ark init-project
```

### Commands
```
Project
    ./ark init-project - Init a project from scratch (Runs through all of the init-project commands)
    ./ark init-project create_env - Prompts the user for values defined in .env.default and saves them to .env
    ./ark init-project build_containers - Builds the docker containers defined in the docker/compose/*.yml files
    ./ark init-project generate_ssl - Generates a self signed ssl certificate for the domain defined in .env
    ./ark init-project update_hosts - Add an alias to localhost for the domain defined in .env
    
Docker - Any extra arguments are passed through to docker-compose
    ./ark docker ssh {container} - Alias for docker-compose exec {container} /bin/bash
    ./ark docker - Alias for docker-compose start
    ./ark docker compose - Alias for docker-compose
    
    Alias commands passed through to docker-compose
    ./ark docker ps
    ./ark docker up
    ./ark docker down 
    ./ark docker stop 
    ./ark docker start 
    ./ark docker restart 
```

### Extending
Any .yml file added to the docker/compose directory will be automatically included as part of the build process and added to the
aliased docker commands. 
