# Use official Bun image
FROM oven/bun:1 AS base
WORKDIR /app

# Step 1: Install dependencies
FROM base AS install
COPY Economy/client Economy/client
COPY Site/package.json Site/bun.lock* Site/
WORKDIR /app/Site
RUN bun install

# Step 2: Build release
FROM base AS release
WORKDIR /app

# Copy dependencies
COPY --from=install /app/Site/node_modules /app/Site/node_modules

# Copy full repository source
COPY Economy /app/Economy
COPY Assets /app/Assets
COPY Site /app/Site
COPY mercury.core.ts /app/mercury.core.ts

WORKDIR /app/Site

# Sync SvelteKit routes and types
RUN bunx svelte-kit sync

# Run build with fallback environment variables if required by SvelteKit static imports
RUN NODE_ENV=production bun run build

# Start the built server
ENTRYPOINT ["bun", "run", "build/index.js"]
