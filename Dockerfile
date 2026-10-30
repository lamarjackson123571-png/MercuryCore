# Step 1: Base image
FROM oven/bun:1 AS base
WORKDIR /app

# Step 2: Install workspace and site dependencies
FROM base AS install

# Copy local dependencies first to resolve file:../Economy/client
COPY Economy/client /app/Economy/client

# Copy package metadata
COPY Site/package.json Site/bun.lock* /app/Site/

WORKDIR /app/Site
RUN bun install

# Step 3: Build application
FROM base AS release
WORKDIR /app

# Copy installed dependencies from install stage
COPY --from=install /app/Site/node_modules /app/Site/node_modules

# Copy full application source files preserving project tree
COPY Economy /app/Economy
COPY Assets /app/Assets
COPY Site /app/Site
COPY mercury.core.ts /app/mercury.core.ts

WORKDIR /app/Site

# Fallback environment variables required during SvelteKit build step
ENV NODE_ENV=production
ENV PORT=3000

# Generate SvelteKit routes and types
RUN bunx svelte-kit sync

# Build production bundle
RUN bun run build

# Step 4: Run Node adapter output
EXPOSE 3000
ENTRYPOINT ["bun", "run", "build/index.js"]
