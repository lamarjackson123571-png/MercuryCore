# Step 1: Base image with Bun + Node.js for Vite SSR compilation
FROM oven/bun:1 AS base
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# Step 2: Install dependencies
FROM base AS install
COPY Economy /app/Economy
COPY Assets /app/Assets
COPY Site/package.json Site/bun.lock* /app/Site/

WORKDIR /app/Site
RUN bun install

# Step 3: Build application
FROM base AS release
WORKDIR /app

# Copy installed node_modules and project source
COPY --from=install /app/Site/node_modules /app/Site/node_modules
COPY Economy /app/Economy
COPY Assets /app/Assets
COPY Site /app/Site
COPY mercury.core.ts /app/mercury.core.ts

WORKDIR /app/Site

# Allocate heap memory to handle Svelte 5 + Vite SSR transforms
ENV NODE_ENV=production
ENV PORT=3000
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Sync SvelteKit routes and dynamic types
RUN bunx svelte-kit sync

# Build production bundle with Node engine
RUN npx vite build

# Step 4: Start app with Bun
EXPOSE 3000
ENTRYPOINT ["bun", "run", "build/index.js"]
