# Using lts-alpine3.20 rather than lts-alpine because it seems the build on 2025-10-29 caused
# an issue here: https://github.com/alangrainger/immich-public-proxy/actions/runs/18898568957/job/53940927581#step:8:212
#
# Later I need to remove the fixed version number and test the build again.
FROM node:lts-alpine3.20 AS builder

USER node
WORKDIR /app
COPY --chown=node:node app/ ./

RUN npm ci \
    && npx tsc

FROM node:lts-alpine3.20 AS runner

RUN apk --no-cache add curl

USER node
WORKDIR /app
COPY --from=builder --chown=node:node app/ ./

RUN npm ci --omit=dev

ARG PACKAGE_VERSION
ENV APP_VERSION=${PACKAGE_VERSION}
ENV NODE_ENV=production

CMD ["node", "dist/index.js" ]
