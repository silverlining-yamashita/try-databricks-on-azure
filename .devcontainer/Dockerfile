FROM --platform=amd64 mcr.microsoft.com/vscode/devcontainers/python:3.12

ARG WORKDIR=/workspace

RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

RUN pip install --upgrade pip && \
    pip install azure-cli pre-commit
