#!/bin/bash

# Return 503 when in maintenance

# Read the HTTP request before replying, so the connection closes cleanly
# instead of being reset (see templates/clustercheck.erb).
while read -r -t 1 line; do
    [ -z "${line%$'\r'}" ] && break
done

body=$'Node is *down*.\r\n'
printf 'HTTP/1.1 503 Service Unavailable\r\nContent-Type: text/plain\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s' \
    "${#body}" "$body"
