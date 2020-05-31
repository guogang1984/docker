# external_url 'http://dev.topflames.com'
# 初始密码，进第一次有效
gitlab_rails['initial_root_password'] = "admin123"
## 反向代理要改对应WEB端口
nginx['listen_port'] = 80;
## GitLab Shell settings for GitLab 默认:22 端口改这里也要改
gitlab_rails['gitlab_shell_ssh_port'] = 22
# 修改时区
gitlab_rails['time_zone'] = 'Asia/Shanghai'
# 需要配置到 gitlab.rb 中的配置可以在这里配置，每个配置一行，注意缩进。
# 比如下面的电子邮件的配置：
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = 'smtp.exmail.qq.com'
gitlab_rails['smtp_port'] = 25
gitlab_rails['smtp_user_name'] = 'support@topflames.com'
gitlab_rails['smtp_password'] = 'Tf123456'
gitlab_rails['smtp_domain'] = 'exmail.qq.com'
gitlab_rails['smtp_authentication'] = :plain
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
# gitlab_email_enabled
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'support@topflames.com'
gitlab_rails['gitlab_email_display_name'] = '驼峰支持'
gitlab_rails['gitlab_email_reply_to'] = 'support@topflames.com'
# backup
# gitlab_rails['manage_backup_path'] = true
# gitlab_rails['backup_path'] = '/var/opt/gitlab/backups'