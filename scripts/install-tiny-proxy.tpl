#! /bin/bash
sudo apt update
sudo apt install tinyproxy -y

sudo systemctl enable tinyproxy
sudo systemctl start tinyproxy
sudo systemctl status tinyproxy