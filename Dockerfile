# use the official Bun image
FROM oven/bun:1 AS base
WORKDIR /app

# Install dependencies
FROM base AS install
COPY Economy/client Economy/client
COPY Site/package.json Site/bun.lock* Site/
# Copy root tsconfig or shared config files if they exist
COPY tsconfig*.json ./
WORKDIR /app/Site
RUN bun install

# Build stage
FROM base AS release
WORKDIR /app

# Copy installed dependencies
COPY --from=install /app/Site/node_modules /app/Site/node_modules

# Copy full application source preserving directory structure
COPY Economy/client /app/Economy/client
COPY Assets /app/Assets
COPY Site /app/Site
COPY mercury.core.ts /app/mercury.core.ts

WORKDIR /app/Site
RUN bun run build

# Run the app
ENTRYPOINT ["bun", "run", "start"]
