FROM node:20-alpine

# Install FFmpeg and SSL certificates for secure RTMPS streams
RUN apk update && \
    apk add --no-cache ffmpeg ca-certificates bash && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Copy dependency specifications and install packages
COPY package.json ./
RUN npm install --omit=dev

# Copy application source code
COPY server.js ./

EXPOSE 3001

CMD ["node", "server.js"]
