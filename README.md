# Activate Django Virtual Env
source venv/bin/activate
# Install all packages
pip3 install -r requirements.txt
# Docker
docker pull python:3.11-slim
docker pull postgres:latest 
docker network create tmapi_default
docker build -t tmapi .
docker compose up 