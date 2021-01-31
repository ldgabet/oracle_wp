#!/bin/sh

# Start crond
echo "crond started"
crond -l 2 -f;
