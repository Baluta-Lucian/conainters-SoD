# entrypoint.sh
#!/bin/sh
set -eu
echo "127.0.0.1 www.schoolofdevops.ro" >> /etc/hosts
exec "$@"
