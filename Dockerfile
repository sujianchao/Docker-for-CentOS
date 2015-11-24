FROM daocloud.io/itjfwcn/centos-systemd:master-init

# 签名
MAINTAINER SuJianchao "sujianchao@gmail.com"

#更新系统，安装git
RUN yum -y update; yum clean all; 
RUN yum install -y git;

# 安装openssh-server和sudo软件包，并且将sshd的UsePAM参数设置成no
RUN yum install -y openssh-server
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
 
# 修改root用户密码
RUN echo "root:sujianchao" | chpasswd
 
# 下面这两句比较特殊，在centos6上必须要有，否则创建出来的容器sshd不能登录
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

# 启动sshd服务并且暴露相关端口
RUN mkdir /var/run/sshd
EXPOSE 22
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
