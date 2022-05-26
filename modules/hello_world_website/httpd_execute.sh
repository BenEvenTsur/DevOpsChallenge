#!/bin/bash

cat <<EOF > index.html
<!DOCTYPE html>
<html>
	<head>
		<title>Hello World Website</title>
        <style>
center{
	color: #7150c7;
    font-size: 40px;
    font-weight: 500;
    font-family: sans-serif;
    margin-top: 30px;
}
        </style>
	</head>
	<body>
		<center>Hello World</center>
	</body>
</html>
EOF

nohup busybox httpd -f -p ${http_port} &