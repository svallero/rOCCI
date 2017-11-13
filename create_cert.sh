#!/bin/sh

openssl req -newkey rsa:2048 -nodes -keyout hostkey.pem -x509 -days 365 -out hostcert.pem

openssl x509 -text -noout -in hostcert.pem
