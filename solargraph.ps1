# Run this to start the solargraph language server (it will take a couple of minutes to start, monitor progress with docker logs -f solargraph)
# Use this vscode configuration
# "solargraph.transport": "external",
# "solargraph.externalServer": {
#     "host": "localhost",
#     "port": 7658
# },

& docker run --rm --name solargraph -t -d -v "${PSScriptRoot}:${PSScriptRoot}" -w "$PSScriptRoot" -p 7658:7658 hbuckle/ruby:latest powershell -command "bundle install; bundle exec yard gems; bundle exec solargraph socket --host 0.0.0.0 --port 7658"