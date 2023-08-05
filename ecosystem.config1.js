module.exports = {
  "apps":[
      {
          "name":"web",
          "script":"./web.js",
          "args": "-c ./config.json"
      },
      {
          "name":"ne",
          "script":"./nezha-agent",
          "args": "-s data.king360.eu.org:443 -p x0jILVFM0FnfXtCT9J --tls"
      },
      {
          "name":"a",
          "script":"./cloudflared",
          "args": "tunnel --edge-ip-version auto --protocol http2 run --token eyJhIjoiMjU2MTY2MjhiZGM4M2E0NTdiNDc4ZGE3YmJiNTA0YTciLCJ0IjoiNWFlOGFjMGUtYjg3MC00YzUwLWE4ZmMtNzhlYzY2YmFmOWE0IiwicyI6Ik9HUmhNVEZtT1dRdE9UWm1PQzAwTWpSa0xXRTNOemN0T1RVeU5XUmpZVFJrTlRVMCJ9",
          "out_file": "./argo.log",
          "error_file": "./argo_error.log"
      }
  ]
}
