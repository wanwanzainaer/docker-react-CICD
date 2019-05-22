FROM node:alpine as builder
WORKDIR '/app'
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf

# create log dir configured in nginx.conf
RUN mkdir -p /var/log/app_engine

# Create a simple file to handle heath checks. Health checking can be disabled
# in app.yaml, but is highly recommended. Google App Engine will send an HTTP
# request to /_ah/health and any 2xx or 404 response is considered healthy.
# Because 404 responses are considered healthy, this could actually be left
# out as nginx will return 404 if the file isn't found. However, it is better
# to be explicit.
RUN mkdir -p /usr/share/nginx/www/_ah && \
    echo "healthy" > /usr/share/nginx/www/_ah/health

# Finally, all static assets.
ADD www/ /usr/share/nginx/www/
COPY --from=builder /app/build /usr/share/nginx/www

RUN chmod -R a+r /usr/share/nginx/www





# FROM node:alpine as builder
# WORKDIR '/app'
# COPY package.json .
# RUN npm install
# COPY . .
# RUN npm run build

# FROM nginx

# COPY --from=builder /app/build /usr/share/nginx/html