#!/bin/sh
# git-export.sh

git archive --format zip --output "~/export-sources.zip" master -0 




git archive --format=zip --prefix=ruoyi-modules/rouyi-devops/ 1.43-1022-alpha > export-sources.zip



ver=1.36-0928-2-alpha
git archive --format=zip --prefix=ruoyi-modules/rouyi-devops/ 1.36-0928-2-alpha > export-sources.zip
