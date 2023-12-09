# Stage 1: Build stage
FROM node:14 as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Stage 2: Serve stage
FROM nginx:alpine
COPY --from=build /app/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
