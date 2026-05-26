# ------------------------------------------------------------------------------
# Backend Dockerfile — Node.js + Express + Prisma Multi-Stage Build
# Security-Hardened, Non-Root, Read-Only Root FS Compatible
# ------------------------------------------------------------------------------

# ==============================================================================
# STAGE 1: Base Image
# ==============================================================================
FROM node:20.11.0-alpine AS base

# Install security updates and dumb-init for proper PID 1 handling
RUN apk upgrade --no-cache && \
    apk add --no-cache \
        dumb-init \
        ca-certificates \
        openssl \
    && rm -rf /var/cache/apk/*

# Create non-root system user (UID 1000 for Node.js convention)
RUN addgroup -g 1000 -S node && \
    adduser -S node -u 1000 -G node

WORKDIR /app

# ==============================================================================
# STAGE 2: Dependencies — Install all packages (including devDependencies)
# ==============================================================================
FROM base AS dependencies

COPY --chown=node:node package.json package-lock.json* ./
COPY --chown=node:node prisma ./prisma/

# Install all dependencies (needed for TypeScript compilation and Prisma generate)
RUN npm ci --ignore-scripts && \
    rm -rf /root/.npm /tmp/*

# Generate Prisma Client with type-safe bindings
RUN npx prisma generate

# ==============================================================================
# STAGE 3: Builder — TypeScript Compilation
# ==============================================================================
FROM dependencies AS builder

# Copy source code
COPY --chown=node:node . .

# Compile TypeScript to JavaScript
ENV NODE_ENV=production
RUN npm run build

# ==============================================================================
# STAGE 4: Production — Minimal Runtime with Compiled Artifacts Only
# ==============================================================================
FROM base AS production

WORKDIR /app

# Copy production dependencies ONLY (no devDependencies)
COPY --chown=node:node package.json package-lock.json* ./
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force && \
    rm -rf /root/.npm /tmp/*

# Copy Prisma schema and generated client (required at runtime)
COPY --chown=node:node --from=dependencies /app/prisma ./prisma/
COPY --chown=node:node --from=dependencies /app/node_modules/.prisma ./node_modules/.prisma/
COPY --chown=node:node --from=dependencies /app/node_modules/@prisma ./node_modules/@prisma/

# Copy compiled JavaScript from builder stage
COPY --chown=node:node --from=builder /app/dist ./dist/

# Create writable directories for read-only root filesystem compatibility
RUN mkdir -p /app/tmp /app/logs && \
    chown -R node:node /app/tmp /app/logs

# Remove unnecessary binaries to minimize attack surface
RUN rm -rf /usr/bin/curl /usr/bin/wget /bin/busybox /sbin/apk /usr/local/bin/npm /usr/local/bin/npx

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV TMPDIR=/app/tmp

# Switch to non-root user
USER node

# Expose application port (documentation only)
EXPOSE 3000

# Health check hitting the live health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

# Use dumb-init for proper signal forwarding and zombie process reaping
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
