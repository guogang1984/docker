#

### README.md

搜索一下，看项目的文件中是否存在CRLF，我搜索php：
find . -type f -name '*.vue' | xargs file |grep CRLF

然后替换其中的dos换行符：
find . -name '*.php' | xargs -I {} perl -pi -e 's/\r//g' {}



###修改所有配置库上的文件为 unix 格式，  CRLF 转 LF
find ./src -name "*.js" | xargs dos2unix
