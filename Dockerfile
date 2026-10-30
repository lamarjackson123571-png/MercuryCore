# Step 1: Base image
FROM oven/bun:1 AS base
WORKDIR /app

# Step 2: Install dependencies
FROM base AS install

# Copy shared modules first
COPY Economy /app/Economy
COPY Assets /app/Assets
COPY Site/package.json Site/bun.lock* /app/Site/

WORKDIR /app/Site
RUN bun install

# Step 3: Build application
FROM base AS release
WORKDIR /app

# Copy installed node_modules and full repository source
COPY --from=install /app/Site/node_modules /app/Site/node_modules
COPY Economy /app/Economy
COPY Assets /app/Assets
COPY Site /app/Site
COPY mercury.core.ts /app/mercury.core.ts

WORKDIR /app/Site

# Fallback environment variables for SvelteKit static checks
ENV NODE_ENV=production
ENV PORT=3000
ENV ORIGIN=http://localhost:3000

# Sync SvelteKit routes and types
RUN bunx svelte-kit sync

# Run Vite build directly using bunx with verbose reporting
RUN bunx vite build

# Step 4: Run Node adapter output
EXPOSE 3000
ENTRYPOINT ["bun", "run", "build/index.js"]
