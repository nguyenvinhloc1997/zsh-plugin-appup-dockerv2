# Docker
_appup_docker () {
    # Try docker compose V2 first (if preferred), then fall back to V1
    local use_v2=false
    
    # Check if V2 is available
    local v2_available=false
    if docker compose version >/dev/null 2>&1; then
        v2_available=true
    fi
    
    # Check if V1 is available
    local v1_available=false
    if hash docker-compose >/dev/null 2>&1; then
        v1_available=true
    fi
    
    # Determine which version to use based on availability and preference
    if [ "$v2_available" = true ] && [ "${APPUP_PREFER_COMPOSE_V2:-true}" = true ]; then
        use_v2=true
    elif [ "$v1_available" = true ]; then
        use_v2=false
    else
        echo >&2 "Neither Docker Compose V2 nor docker-compose V1 is available."
        return 1
    fi

    # Check if docker has been started
    if [ "${APPUP_CHECK_STARTED:-true}" = true ]; then
        if hash docker-machine >/dev/null 2>&1 && [ "${APPUP_DOCKER_MACHINE:-true}" = true ]; then            
            if docker-machine status | grep -qi "Stopped"; then
                read -r -k 1 "REPLY?Docker Machine is not running, would you like to start it? [y/N] "
                echo ""
                
                if [[ "$REPLY" == "y" ]]; then
                    docker-machine start default && eval $(docker-machine env default)
                    echo ""
                else
                    return 0
                fi
            fi
        elif docker ps 2>&1 | grep -qi "Is the docker daemon running?"; then
            read -r -k 1 "REPLY?Docker for Mac is not running, would you like to start it? [y/N] "
            echo ""
            
            if [[ "$REPLY" == "y" ]]; then
                open -a Docker
                
                echo ""
                echo "Waiting for docker to start.."
                echo ""

                # Wait for it to start
                while true; do
                    if docker ps 2>&1 | grep -qi "Is the docker daemon running?" || docker ps 2>&1 | grep -qi "connection refused"; then
                        sleep 5
                    else
                        break
                    fi
                done
            else
                return 0
            fi
        fi
    fi
    
    # Find docker-compose file
    compose_file=''
    
    if [ -e "docker-compose.yml" ]; then
        compose_file='docker-compose.yml'
    elif [ -e "docker-compose.yaml" ]; then
        compose_file='docker-compose.yaml'
    fi

    # Env files
    env_files=()

    if [ "${APPUP_LOAD_ENVS:-true}" = true ]; then
        if [ -e ".env" ]; then
            env_files+=( .env )
        fi
        if [ -e ".env.local" ]; then
            env_files+=( .env.local )
        fi
        if [ -e ".env.docker" ]; then
            env_files+=( .env.docker )
        fi
        if [ -e ".env.docker.local" ]; then
            env_files+=( .env.docker.local )
        fi
    fi
    
    # <cmd> <project name> will look for docker-compose.<project name>.yml
    if [ -n "$2" ]; then
        # Find project-specific docker-compose file
        compose_project_file=''

        if [ -e "docker-compose.$2.yml" ]; then
            compose_project_file="docker-compose.$2.yml"
        elif [ -e "docker-compose.$2.yaml" ]; then
            compose_project_file="docker-compose.$2.yaml"
        fi

        if [ -n "$compose_project_file" ]; then
            # Project specific env file
            if [ "${APPUP_LOAD_ENVS:-true}" = true ]; then
                if [ -e ".env.$2" ]; then
                    env_files+=( ".env.$2" )
                fi
                if [ -e ".env.$2.local" ]; then
                    env_files+=( ".env.$2.local" )
                fi
            fi

            # Run docker compose
            if [ "$use_v2" = true ]; then
                docker compose -f "$compose_file" -f "$compose_project_file" --env-file=$^env_files $1 "${@:3}"
            else
                docker-compose -f "$compose_file" -f "$compose_project_file" --env-file=$^env_files $1 "${@:3}"
            fi

            return
        fi
    fi

    # Run docker compose
    if [ "$use_v2" = true ]; then
        docker compose --env-file=$^env_files $1 "${@:2}"
    else
        docker-compose --env-file=$^env_files $1 "${@:2}"
    fi
}

# Vagrant
_appup_vagrant () {
    if hash vagrant >/dev/null 2>&1; then
        vagrant $1 "${@:2}"
    else
        echo >&2 "Vagrant file found but vagrant is not installed."
    fi
}

# Commands
up () {
    if [ -e "docker-compose.yml" ] || [ -e "docker-compose.yaml" ]; then
        _appup_docker up "$@"
    elif [ -e "Vagrantfile" ]; then
        _appup_vagrant up "$@"
    elif hash up >/dev/null 2>&1; then
        env up "$@"
    fi
}

down () {
    if [ -e "docker-compose.yml" ] || [ -e "docker-compose.yaml" ]; then
        _appup_docker down "$@"
    elif [ -e "Vagrantfile" ]; then
        _appup_vagrant destroy "$@"
    elif hash down >/dev/null 2>&1; then
        env down "$@"
    fi
}

start () {
    if [ -e "docker-compose.yml" ] || [ -e "docker-compose.yaml" ]; then
        _appup_docker start "$@"
    elif [ -e "Vagrantfile" ]; then
        _appup_vagrant up "$@"
    elif hash start >/dev/null 2>&1; then
        env start "$@"
    fi
}

restart () {
    if [ -e "docker-compose.yml" ] || [ -e "docker-compose.yaml" ]; then
        _appup_docker restart "$@"
    elif [ -e "Vagrantfile" ]; then
        _appup_vagrant reload "$@"
    elif hash start >/dev/null 2>&1; then
        env start "$@"
    fi
}

stop () {
    if [ -e "docker-compose.yml" ] || [ -e "docker-compose.yaml" ]; then
        _appup_docker stop "$@"
    elif [ -e "Vagrantfile" ]; then
        _appup_vagrant halt "$@"
    elif hash stop >/dev/null 2>&1; then
        env stop "$@"
    fi
}

enter () {
    if [ -e "docker-compose.yml" ] || [ -e "docker-compose.yaml" ]; then
        CMD=( "${@:2}" )

        if [ $# -eq 1 ]; then
            CMD=( /bin/bash -l )
        fi

        _appup_docker exec "$1" $CMD
    elif hash enter >/dev/null 2>&1; then
        env enter "$@"
    fi   
}
