uid=0
gid=0
use chroot = false
strict modes = false
hosts allow = *
log file = rsyncd.log

# Module definitions
# Remember cygwin naming conventions : c:\work becomes /cygwin/c/work

[u_sql] 
#需要做镜像同步的目录，如d:/testD:\发布目录\脚本目录\自动备份
path = /cygdrive/d/发布目录/脚本目录/自动备份
#可以忽略一些无关的IO错误
ignore errors=yes
read only = false
#认证的用户名，如果没有这行，则表明是匿名
auth users=uploadUser
#认证文件名
secrets file=/etc/rsyncd.uploadUser.pas
transfer logging = yes

[u_release] 
path = /home/dev/DevProjectFiles/ws-release/
ignore errors=yes
read only = false
auth users=uploadUser
secrets file=/etc/uploadUser.pas
transfer logging = yes

[release] 
#需要做镜像同步的目录，如d:/test
path = /home/dev/DevProjectFiles/ws-release/
#可以忽略一些无关的IO错误
ignore errors=yes
read only = false
#认证的用户名，如果没有这行，则表明是匿名
auth users=downloadUser
#认证文件名
secrets file=/etc/rsyncd.downloadUser.pas
transfer logging = yes


