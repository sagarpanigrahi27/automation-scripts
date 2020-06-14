#!/bin/bash

sudo grep -q "^PubkeyAuthentication" /etc/ssh/sshd_config && sudo sed "s/^PubkeyAuthentication=.*/PubkeyAuthentication yes/" -i /etc/ssh/sshd_config || sudo sed "$ a\PubkeyAuthentication yes" -i /etc/ssh/sshd_config

sudo grep -q "^AuthorizedKeysFile" /etc/ssh/sshd_config && sudo sed "s/^AuthorizedKeysFile=.*/AuthorizedKeysFile %h\/.ssh\/authorized_keys/" -i /etc/ssh/sshd_config || sudo sed "$ a\AuthorizedKeysFile %h/.ssh/authorized_keys" -i /etc/ssh/sshd_config
