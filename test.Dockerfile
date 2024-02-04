FROM ubuntu:22.04

RUN apt update && \
    apt install -y curl zip unzip && \
    curl -L -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_arm64 && \
    chmod +x /usr/local/bin/yq && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    curl -L -o terraform.zip https://releases.hashicorp.com/terraform/1.7.2/terraform_1.7.2_linux_arm64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform

COPY run.sh /run.sh

ENV AWS_PAGER=""

ENTRYPOINT [ "bash", "-c", "/run.sh" ]
