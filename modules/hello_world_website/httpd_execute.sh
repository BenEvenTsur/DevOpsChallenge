#!/bin/bash

echo "<html><body><p>Hello World</p></body></html>" > index.html
nohup busybox httpd -f -p ${http_port} &