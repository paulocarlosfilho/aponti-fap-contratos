# 📑 API de Contratos - Infraestrutura & Pipeline DevSecOps

Este repositório contém a infraestrutura conteinerizada, a automação de Infraestrutura como Código (IaC), o ecossistema de observabilidade e a pipeline de CI/CD DevSecOps para o microserviço de **Contratos**.

---

## 🏛️ Justificativa de Arquitetura e Engenharia

A solução foi projetada seguindo rigorosamente os princípios de **DevOps** e **DevSecOps**, garantindo automação, rastreabilidade, alta disponibilidade e segurança desde as primeiras fases do ciclo de vida (*Shift Left*):

### 1. Conteinerização Multi-Stage e Segurança do Runtime
* **Build Eficiente:** A aplicação utiliza o padrão *Multi-Stage Build* no Docker (`node:20-alpine`). Na primeira etapa (*builder*), são instaladas as dependências de desenvolvimento e realizada a compilação TypeScript (`npm run build`). Na segunda etapa (*runner*), apenas os artefatos compilados em JavaScript (`dist/`) e as dependências de produção são copiados.
* **Redução da Superfície de Ataque:** A imagem final é enxuta e livre de compiladores ou ferramentas de dev.
* **Princípio do Menor Privilégio:** O container executa obrigatoriamente sob o usuário não-root `node`, prevenindo ataques de elevação de privilégio.

### 2. Infraestrutura como Código (IaC) com Terraform & LocalStack
* **Provisionamento Declarativo:** A infraestrutura de nuvem é declarada via Terraform (`terraform/main.tf`).
* **Ambiente Local Seguro:** Para simular o ambiente AWS sem custos e de forma reprodutível, os endpoints apontam para o **LocalStack**, provisionando um bucket S3 (`contratos-api-storage`) pronto para o armazenamento de documentos/contratos.

### 3. Pipeline de CI/CD & DevSecOps (Shift Left)
A pipeline automatizada no GitHub Actions (`.github/workflows/ci-cd.yml`) inclui 5 camadas de validação e segurança:
* **Gitleaks (Secret Detection):** Analisa o código em busca de senhas, tokens ou chaves privadas expostas.
* **SAST (CodeQL):** Executa análise estática de código no TypeScript para identificar vulnerabilidades e má qualidade de código.
* **Checkov (IaC Scan):** Audita a segurança dos manifestos de infraestrutura (`Dockerfile`, `docker-compose.yml` e `main.tf`).
* **Trivy (Container & Dependency Scan):** Varre a imagem Docker gerada e os pacotes Node.js em busca de CVEs críticas e altas.
* **DAST (OWASP ZAP):** Realiza testes dinâmicos de penetração contra a API em execução no ambiente temporário da pipeline.

### 4. Observabilidade (Prometheus + Grafana)
* **Coleta de Métricas:** A API expõe métricas em tempo real na rota `/metrics`.
* **Raspagem e Visualização:** O **Prometheus** raspa periodicamente as métricas da aplicação, tornando os dados disponíveis para dashboards e alertas configuráveis no **Grafana**.

---

## 📂 Estrutura do Projeto

```text
Contratos/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # Pipeline DevSecOps Completa (Gitleaks, SAST, Checkov, Trivy, DAST)
├── terraform/
│   └── main.tf                # Provedor AWS + LocalStack (Bucket S3)
├── monitoring/
│   └── prometheus.yml         # Configuração de raspagem de métricas
├── .dockerignore              # Arquivos ignorados no build do container
├── Dockerfile                 # Multi-stage build (Node 20 Alpine)
├── docker-compose.yml         # Orquestração (App, Redis, LocalStack, Prometheus, Grafana)
└── README.md                  # Documentação de infraestrutura e execução
```

## 🛠 Como Executar o Ambiente Localmente

### Pré-requisitos
* **Docker** instalado
* **Docker Compose** instalado

### 1. Subindo todo o ecossistema

Na raiz da pasta `Contratos/`, execute o comando abaixo para subir a API, o banco Redis, o LocalStack (AWS S3), o Prometheus e o Grafana:

```bash
docker-compose up -d --build
```

### 2. Verificando o status dos serviços
Para confirmar se todos os contêineres estão saudáveis e em execução:

```Bash
docker-compose ps
```

### 3. Acompanhando os logs da API
```Bash
docker-compose logs -f app
```
### 4. Encerrando e limpando o ambiente
```Bash
docker-compose down
```

### 🌐 Endpoints e Portas do Ambiente

API Contratos: http://localhost:3000/contracts

Healthcheck: http://localhost:3000/

Métricas Prometheus Expostas: http://localhost:3000/metrics

LocalStack (AWS S3 Mock): http://localhost:4566

Prometheus UI: http://localhost:9090

Grafana Dashboard: http://localhost:3001 (Login: admin | Senha: admin)

### 🧪 Executando os Testes Automatizados
Para rodar a suíte de testes unitários e de integração (Jest) diretamente na máquina local:

```Bash
# Instalar as dependências do projeto
npm install

# Executar a suíte de testes
npm test

```