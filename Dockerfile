# image for build process
FROM node:12.18.1
# Sets working directory
WORKDIR /app
# Moves the contents of the app package into it's parent directory
COPY app/ ./
RUN ls -la /app/*
RUN npm install
# Specfifes port that will be exposed for given container
EXPOSE 3000
# Defines environment variables that are avaiable within the container
ENV SECRET_WORD MYNAMEISNODE
# Executes the start command
CMD ["npm", "start"]