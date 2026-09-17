FROM node:22-alpine AS base
RUN corepack enable
WORKDIR /workspace

FROM base AS dependencies
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/api/package.json apps/api/package.json
RUN pnpm install --frozen-lockfile

FROM dependencies AS build
COPY apps/api apps/api
COPY assets/fonts/Tajawal assets/fonts/Tajawal
RUN pnpm --filter @alif/api prisma:generate && pnpm --filter @alif/api build

FROM node:22-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /workspace/apps/api/dist ./dist
COPY --from=build /workspace/apps/api/prisma ./prisma
COPY --from=build /workspace/assets/fonts/Tajawal ./assets/fonts/Tajawal
COPY --from=dependencies /workspace/node_modules ./node_modules
COPY --from=build /workspace/apps/api/package.json ./package.json
USER node
CMD ["node", "dist/main.js"]
