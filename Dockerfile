FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app

EXPOSE 8080
EXPOSE 8081

# Estágio de build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["CrowdinExtractorWebhook.Api/CrowdinExtractorWebhook.Api.csproj", "CrowdinExtractorWebhook.Api/"]

# Restaurar as dependências
RUN dotnet restore "CrowdinExtractorWebhook.Api/CrowdinExtractorWebhook.Api.csproj"

# Copiar o resto do código-fonte
COPY . .

# Build da aplicação
WORKDIR "/src/CrowdinExtractorWebhook.Api"
RUN dotnet build "CrowdinExtractorWebhook.Api.csproj" -c Release -o /app/build

# Estágio de publicação
FROM build AS publish
RUN dotnet publish "CrowdinExtractorWebhook.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app

# Copiar os arquivos publicados
COPY --from=publish /app/publish .

ENV ASPNETCORE_URLS="http://+:8080"
ENV DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0

ENTRYPOINT ["dotnet", "CrowdinExtractorWebhook.Api.dll"]