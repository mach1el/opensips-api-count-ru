#!/bin/bash

revert_config() {
  cp "${API_SERVER_CONF}.backup" "${API_SERVER_CONF}"
}

config_db() {
  cp "${API_SERVER_CONF}" "${API_SERVER_CONF}.backup"

  if ! compgen -A variable | grep -q -E "API_DB_HOST"; then
    echo "[$(date)][DEBUG] NO API_DB_HOST variable detected"
    revert_config
    return 1
  fi

  API_DB_PORT=${API_DB_PORT:-5432}

  if ! compgen -A variable | grep -q -E "API_DB_USER"; then
    echo "[$(date)][DEBUG] NO API_DB_USER variable detected"
    revert_config
    return 1
  fi

  if ! compgen -A variable | grep -q -E "API_DB_PASSWORD"; then
    echo "[$(date)][DEBUG] NO API_DB_PASSWORD variable detected"
    revert_config
    return 1
  fi

  API_DB_NAME=${API_DB_NAME:-opensips}

  {
    echo "[node]"
    echo "db_host=$API_DB_HOST"
    echo "db_port=$API_DB_PORT"
    echo "db_user=$API_DB_USER"
    echo "db_password=$API_DB_PASSWORD"
    echo "db_name=$API_DB_NAME"
  } > "$API_SERVER_CONF"

}

init_vars() {
  API_AUTOCONF=${API_AUTOCONF:-true}
  API_SERVER_CONF="/pyapp/servers"
  local run_cmd="python3 /pyapp/app.py"
  API_RUN="$run_cmd"
}

main() {
  init_vars
  if [[ ${API_AUTOCONF} == "true" ]]; then
    config_db
  fi
  exec $API_RUN
}

main