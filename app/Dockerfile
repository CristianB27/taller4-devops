FROM node:22-alpine

ARG GIT_SHA=unknown
ENV NODE_ENV=production \
    PORT=3000 \
    APP_VERSION=${GIT_SHA}

WORKDIR /app
COPY package.json server.js ./
RUN chown -R node:node /app

USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1

CMD ["node", "server.js"]
