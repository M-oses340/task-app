# Use Node 20
FROM node:20

# Set working directory
WORKDIR /app

# Install dependencies first (better cache usage)
COPY package*.json ./
RUN npm install

# Copy remaining source code
COPY . .

# Enable proper file watching inside Docker
ENV CHOKIDAR_USEPOLLING=true
ENV CHOKIDAR_INTERVAL=200

# Expose backend port
EXPOSE 8000

# Run dev mode with nodemon + ts-node/esm
CMD ["npm", "run", "dev"]
