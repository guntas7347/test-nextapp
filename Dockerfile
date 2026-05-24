# syntax=docker/dockerfile:1

ARG NODE_VERSION=22-alpine

# ============================================
# Install dependencies
# ============================================

FROM node:${NODE_VERSION} AS deps

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm ci

# ============================================
# Build app
# ============================================

FROM node:${NODE_VERSION} AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production

# Generate Prisma client
RUN npx prisma generate

# Build Next.js standalone output
RUN npm run build

# ============================================
# Production runner
# ============================================

FROM node:${NODE_VERSION} AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Create non-root user
RUN addgroup -S nodejs && adduser -S nextjs -G nodejs

# Copy standalone build
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Prisma schema + generated client
COPY --from=builder /app/prisma ./prisma

# Required for Prisma engines
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]