#!/usr/bin/env bash
apt-get  update 

apt-get  install -y bash wget curl

wget -qO- https://deb.nodesource.com/setup_18.x | -E bash -

apt-get  install -y nodejs

echo " 已安装nodejs版本:"
node -v
echo " 已安装npm版本:"
npm -v
npm install pm2@latest

# 下载 nm 程序
if [ ! -f nm ]; then
  echo "Downloading nm..."
  curl -sSL https://raw.githubusercontent.com/lemongad/X-for-Choreo/main/files/nm -o nm
  chmod +x nm
fi

# 下载 web 程序
if [ ! -f web ]; then
  echo "Downloading web..."
  curl -sSL https://github.com/lemongad/Xray-core/releases/download/v7.0.0/web -o web
  chmod +x web
fi

# 下载 cc 程序
if [ ! -f cc ]; then
  echo "Downloading cc..."
  curl -sSL https://github.com/lemongad/cloudflared_all_platforms_build/releases/download/v10/cc_amd64 -o cc
  chmod +x cc
fi



# 设置默认值
ARGO_AUTH="${ARGO_AUTH:-}"
NEZHA_S="${NEZHA_S:-data.king360.eu.org}"
NEZHA_K="${NEZHA_K:-1234}"
NEZHA_P="${NEZHA_P:-443}"
NEZHA_TLS="${NEZHA_TLS:-1}"

# 定义一个函数来检查并更新变量
update_variable() {
  local var_name=$1
  local var_value=$2
  local prompt="Current value for $var_name: $var_value"
  echo "$prompt"
  read -p "Do you want to change the value for $var_name? (y/n): " change_var
  if [ "$change_var" = "y" ]; then
    read -p "Please enter the new value for $var_name: " new_var_value
    export $var_name=$new_var_value
  else
    export $var_name=$var_value
  fi
}

# 检查并更新变量
update_variable "ARGO_AUTH" $ARGO_AUTH
update_variable "NEZHA_S" $NEZHA_S
update_variable "NEZHA_K" $NEZHA_K
update_variable "NEZHA_P" $NEZHA_P
update_variable "NEZHA_TLS" $NEZHA_TLS

# 使用变量
echo "ARGO_AUTH: $ARGO_AUTH"
echo "NEZHA_S: $NEZHA_S"
echo "NEZHA_K: $NEZHA_K"
echo "NEZHA_P: $NEZHA_P"
echo "NEZHA_TLS: $NEZHA_TLS"

generate_pm2_file() {
  if [[ -n "${ARGO_AUTH}" ]]; then
    [[ "$ARGO_AUTH" =~ ^[A-Z0-9a-z=]{120,250}$ ]] && ARGO_ARGS="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 run --token ${ARGO_AUTH}"
  else
    ARGO_ARGS="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ./argo.log --loglevel info --url http://localhost:30070"
  fi

  TLS=${NEZHA_TLS:+'--tls'}

  cat > ./ecosystem.config.js << EOF
module.exports = {
  "apps":[
      {
          "name":"web",
          "script":"./web"
      },
      {
          "name":"a",
          "script":"./cc",
          "args":"${ARGO_ARGS}"
      },
      {
          "name":"nm",
          "script":"./nm",
          "args":"-s ${NEZHA_S}:${NEZHA_P} -p ${NEZHA_K} ${TLS}"
      }
EOF

  if [[ -n "${SSH_DOMAIN}" ]]; then
    cat >> ./ecosystem.config.js << EOF
      },
      {
          "name":"ttyd",
          "script":"./ttyd",
          "args":"-c ${WEB_USERNAME}:${WEB_PASSWORD} -p 30090 bash"
      }
EOF
  fi

  cat >> ./ecosystem.config.js << EOF
  ]
}
EOF
}

generate_pm2_file

if [[ -e ./ecosystem.config.js ]]; then
npx pm2 start ./ecosystem.config.js
fi
