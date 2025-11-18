FROM node:20

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 8000

CMD ["npx", "nodemon", "--loader", "ts-node/esm", "src/index.ts"]
