FROM node:12

# Create app directory
WORKDIR /usr/src/app

# Only copy the package.json file to work directory
COPY package*.json ./

# ENV REACT_APP_ENV staging

# Install app dependencies
RUN npm install

# Bundle app source
COPY . .

RUN npm run build

EXPOSE 3000

CMD [ "npm", "start" ]
