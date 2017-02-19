FROM node:7.5.0
ADD package.json .
RUN npm install
ADD index.js .
ADD spec.js .
ADD main.js .
CMD ["node", "--harmony", "index.js"]
