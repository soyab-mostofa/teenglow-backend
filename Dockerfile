# Define base image
FROM node:18.8-alpine as base

# Define build arguments for sensitive data
ARG DATABASE_URI
ARG PAYLOAD_SECRET

FROM base as builder

WORKDIR /home/node/app

# Copy only necessary files for installation
COPY package*.json ./

# Copy all files to container and install dependencies
COPY . .
RUN yarn install
RUN yarn build

FROM base as runtime

# Pass the arguments as environment variables
ENV NODE_ENV=production
ENV PAYLOAD_CONFIG_PATH=dist/payload.config.js
ENV DATABASE_URI=$DATABASE_URI
ENV PAYLOAD_SECRET=$PAYLOAD_SECRET

WORKDIR /home/node/app
COPY package*.json  ./
# COPY yarn.lock ./

RUN yarn install --production
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/build ./build

EXPOSE 8000

CMD ["node", "dist/server.js"]
