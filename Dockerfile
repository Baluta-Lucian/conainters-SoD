FROM alpine:latest

# Install nginx
RUN apk add --no-cache nginx && \
    mkdir -p /run/nginx /usr/share/nginx/html && \
    rm -rf /var/www/*

# Copy the nginx config
COPY nginx/default.conf /etc/nginx/http.d/default.conf

# Copy the index.html to container
COPY site/ /usr/share/nginx/html/

# Set the loopback address to point to www.schoolofdevops.ro
# RUN echo "127.0.0.1 www.schoolofdevops.ro" >> /etc/hosts
# COPY ./scripts/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]

#expose the service
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]