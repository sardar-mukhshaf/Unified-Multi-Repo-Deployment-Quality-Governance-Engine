# ------------------------------------------------------------------------------
# Frontend Dockerfile — React + Vite Multi-Stage Build
# Security-Hardened, Banking-Grade Container Image
# Target Size: < 120MB (compressed)
# ------------------------------------------------------------------------------

# ==============================================================================
# STAGE 1: Base Dependencies
# ==============================================================================
FROM node:20.11.0-alpine AS base

# Install security updates and essential build dependencies
RUN apk add --no-cache \
    dumb-init \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Create non-root system user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactuser -u 1001 -G nodejs

WORKDIR /app

# ==============================================================================
# STAGE 2: Dependency Installation
# ==============================================================================
FROM base AS deps

# Copy package manifests first for optimal layer caching
COPY --chown=reactuser:nodejs package.json package-lock.json* ./

# Install production dependencies only with audit
RUN npm ci --only=production --ignore-scripts && \
    npm audit --production --audit-level=moderate || true && \
    rm -rf /root/.npm /tmp/*

# ==============================================================================
# STAGE 3: Build Stage — TypeScript Compilation & Vite Bundle
# ==============================================================================
FROM base AS builder

# Install dev dependencies for build
COPY --chown=reactuser:nodejs package.json package-lock.json* ./
RUN npm ci --ignore-scripts && rm -rf /root/.npm /tmp/*

# Copy source code
COPY --chown=reactuser:nodejs . .

# Build the production bundle
ENV NODE_ENV=production
ENV VITE_APP_ENV=production
RUN npm run build

# ==============================================================================
# STAGE 4: Production Runtime — Security-Hardened NGINX
# ==============================================================================
FROM nginx:1.25.3-alpine-slim AS production

# Install security updates
RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates dumb-init && \
    rm -rf /var/cache/apk/* /usr/share/nginx/html/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactuser -u 1001 -G nodejs

# Copy hardened NGINX configuration
COPY --chown=reactuser:nodejs docker/nginx.conf /etc/nginx/nginx.conf
COPY --chown=reactuser:nodejs docker/security-headers.conf /etc/nginx/conf.d/security-headers.conf

# Copy built application from builder stage
COPY --chown=reactuser:nodejs --from=builder /app/dist /usr/share/nginx/html

# Set proper permissions for read-only root filesystem compatibility
RUN chown -R reactuser:nodejs /usr/share/nginx/html && \
    chown -R reactuser:nodejs /var/cache/nginx && \
    chown -R reactuser:nodejs /var/log/nginx && \
    chown -R reactuser:nodejs /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R reactuser:nodejs /var/run/nginx.pid

# Remove unnecessary tools to minimize attack surface
RUN rm -rf /usr/bin/curl /usr/bin/wget /bin/busybox /sbin/apk

# Switch to non-root user
USER reactuser

# Expose port (documentation only; no privilege needed)
EXPOSE 8080

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Use dumb-init for proper signal handling (PID 1)
ENTRYPOINT ["dumb-init", "--"]
CMD ["nginx", "-g", "daemon off;"]
