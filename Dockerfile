FROM node:22-alpine

WORKDIR /app

COPY build build/
COPY package*.json .
COPY node_modules node_modules/
COPY server-wrapper server-wrapper/

EXPOSE 3000

ENV NODE_ENV=production

CMD [ "node", "server-wrapper" ]
