FROM node:22
RUN apt update && apt install -y jq
COPY ./server-wrapper /app/server-wrapper
RUN mkdir /app/build && echo 'export const handler = {}' > /app/build/handler.js
WORKDIR /app
RUN npm install express cors ws && cat package.json | jq '.type = "module"' > package2.json && mv package2.json package.json
CMD ["node", "/app/server-wrapper"]
