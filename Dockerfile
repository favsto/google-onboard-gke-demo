FROM node:9.7.1
EXPOSE 8080
COPY index.html .
COPY server.js .
CMD node server.js