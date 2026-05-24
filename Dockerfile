# syntax=docker/dockerfile:1

ARG NODE_VERSION=22-alpine

# ============================================
# Dependencies
# ============================================

FROM node:${NODE_VERSION} AS deps

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN corepack enable && \
    pnpm install --frozen-lockfile --ignore-scripts=false

# ============================================
# Builder
# ============================================

FROM node:${NODE_VERSION} AS builder

WORKDIR /app

ENV NODE_ENV=production

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN corepack enable

# Generate Prisma client
RUN pnpm prisma generate

# Build Next.js standalone app
RUN pnpm build

# ============================================
# Runner
# ============================================

FROM node:${NODE_VERSION} AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

# Create non-root user
RUN addgroup -S nodejs && \
    adduser -S nextjs -G nodejs

# Standalone server
COPY --from=builder /app/.next/standalone ./

# Static assets
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Prisma
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]