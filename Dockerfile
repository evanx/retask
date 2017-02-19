FROM node:7.5.0
ADD package.json .
RUN npm install
ADD app .
CMD ["node", "--harmony", "app/index.js"]
