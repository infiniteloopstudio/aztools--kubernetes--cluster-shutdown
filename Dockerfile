FROM mcr.microsoft.com/azure-cli

RUN apk update && apk upgrade

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
