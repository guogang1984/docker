https://confluence.atlassian.com/adminjiraserver087/connecting-jira-applications-to-mysql-5-7-998871501.html

# docker build -t g127/jira .

 docker run  --name jira --restart=unless-stopped -p 9083:8080 --link mysql:mysql  \
  -v /home/dev/DevProjectFiles/ws-data/jira:/var/jira -d g127/jira

DROP USER jira, jira@localhost;
DROP DATABASE jiradb IF EXISTS;
CREATE DATABASE jiradb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
create user jira identified by 'jira';
grant all privileges on jiradb.* to 'jira'@'localhost' identified by 'jira' with grant option;
grant all privileges on jiradb.* to 'jira'@'%' identified by 'jira' with grant option;
flush privileges;


# BH2M-X79I-M3GM-ULJC

AAABpA0ODAoPeJyNkt2OmzAQhe95CqRem8XOpkAkpGYBbVlBUpWk7a1DJhuviLHGJtv06WsCq+5PF
FWykIzmHH9zZj79hK07V+gy5rLJbBrNaOAm1cplPvOdRwSQ+1YpQK8QNUgNq5OCBT9AnCzLMvue5
PPCSRC4Ea1MuYG4FxL/ljDmXJGkoGsUqlfFa9mIgzAWpBkE7ubk7o1RenZz82cvGvBE65RcSAOSy
xqy30rgaXwtjIgf2OM8CeQvlNlWDNaLIi/zVZY6i+6wAVzu1hpQx4S+wF3xUthuu9p4/YXodmeeO
YL3wehKLa+NOEJssIM3Wb7+f0VuqXgCtmscSsd4ftiH++aYU3WbfzGeS7Ijb7rzMOIdb/Ro/95oi
Y9cCj3U9UnboCmNvIlHw1uPRmwW+eHESVppLGpmo29iA9p86T9e3R4G28tR/GdzleHYAw2Y4zTyN
C7ytMoWpKDTMJgGlE6Dzyx8M9xL+1QBHgGt/O4rK8mvIMpJObkvybp4SC6t8ccF+dZhveca3i/xa
/E5QoVCj+1Z0PgC7JjbmfFuvvoLQ4AngDAuAhUAkZRlbLeivrYZQkEeVZ7UWfOju70CFQCSmE12m
I3MRLCTiAL0pC3KlOJDMw==X02kc