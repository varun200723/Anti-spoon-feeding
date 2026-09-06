# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM node:20-alpine
WORKDIR /app

# Copy deps from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application files
COPY server.js ./
COPY code.html ./
COPY chat.html ./

# Cloud Run sets PORT env var automatically
ENV PORT=8080
ENV NODE_ENV=production

EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:8080/api/health || exit 1

CMD ["node", "server.js"]
