FROM node:14

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .

ENV PORT 3000
ENV BASE_PATH /api

EXPOSE $PORT

CMD ["node", "server.js"]
