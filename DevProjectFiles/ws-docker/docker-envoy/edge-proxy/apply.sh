#!/bin/sh

# apply.sh
# Docker 对 inotify 的支持不太友好，有时不会检测不到文件系统的更改，所以最好的办法是强制更改

# envoy-cds.yaml 
mv envoy-cds.yaml envoy-cds.yaml.temp
mv envoy-cds.yaml.temp envoy-cds.yaml

# envoy-lds.yaml
mv envoy-lds.yaml envoy-lds.yaml.temp
mv envoy-lds.yaml.temp envoy-lds.yaml