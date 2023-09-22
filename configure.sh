#!/bin/sh

yes "y" | ssh-keygen -o -a 100 -t ed25519 -C "ubuntu-swift-sample" -f ./key/key -N ""
