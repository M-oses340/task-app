# Use Node 20
FROM node:20

# Set working directory
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dependencies (including dev dependencies for live reload)
RUN npm install

# Copy the rest of the code
COPY . .

# Expose backend port
EXPOSE 8000

# Run in development mode with live reload
CMD ["npm", "run", "dev"]
