FROM node:7.5.0
ADD package.json .
RUN npm install
ADD *.js .
CMD ["node", "--harmony", "index.js"]
