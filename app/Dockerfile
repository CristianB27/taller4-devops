FROM node:22-alpine

ARG GIT_SHA=unknown
ENV NODE_ENV=production \
    PORT=3000 \
    APP_VERSION=${GIT_SHA}

# La app no usa gestores de paquetes en runtime: se eliminan npm, yarn y corepack,
# que son los que traen las dependencias vulnerables que reporta Trivy.
RUN rm -rf \
      /usr/local/lib/node_modules/npm \
      /usr/local/lib/node_modules/corepack \
      /usr/local/bin/npm \
      /usr/local/bin/npx \
      /usr/local/bin/corepack \
      /usr/local/bin/yarn \
      /usr/local/bin/yarnpkg \
      /opt/yarn-*

WORKDIR /app
COPY package.json server.js ./
RUN chown -R node:node /app

USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1

CMD ["node", "server.js"]