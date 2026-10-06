# --- STAGE 1: Build (Instala tudo e compila TypeScript) ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --- STAGE 2: Runtime (Apenas dependências de prod + JS compilado) ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copia os arquivos compilados da etapa anterior (dist/)
COPY --from=builder /app/dist ./dist

# Healthcheck nativo embutido no container
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', res => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

# Segurança: Usuário não-root
USER node

EXPOSE 3000

CMD ["node", "dist/server.js"]