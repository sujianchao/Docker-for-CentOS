# Docker-for-CentOS
给自己测试用的Docker-for-CentOS

#systemd 整合

当前，因为 systemd 要求 CAP_SYS_ADMIN 权限，从而得到了读取主机 cgroup 的能力，CentOS7 中已经用 fakesystemd 代替了 systemd 来解决依赖问题。 如果您仍然希望使用 systemd，可用参考下面的 Dockerfile：
<pre><core>
FROM daocloud.io/centos:7
MAINTAINER "you" <your@email.here>
ENV container docker
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i ==
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
</core></pre>
上面这个Dockerfile首先删除了 fakesystemd 并且安装了 systemd。然后您就可以构建基础镜像了。
<pre><core>
docker build --rm -t local/c7-systemd .
</core></pre>
#一个包含 systemd 的应用容器示例

为了使用像上面那样包含 systemd 的容器，你需要创建一个类似下面的Dockerfile：
<pre><core>
FROM local/c7-systemd
RUN yum -y install httpd; yum clean all; systemctl enable httpd.service
EXPOSE 80
CMD ["/usr/sbin/init"]
</core></pre>
构建镜像:
<pre><core>
docker build --rm -t local/c7-systemd-httpd
</core></pre>
#运行一个包含 systemd 的应用容器

为了运行一个包含 systemd 的容器，您需要使用--privileged选项， 并且挂载主机的 cgroups 文件夹。 下面是运行包含 systemd 的 httpd 容器的示例命令：
<pre><core>
docker run --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 80:80 local/c7-systemd-httpd
</core></pre>
#支持的Docker版本

这个镜像在 Docker 1.7.0 上提供最佳的官方支持，对于其他老版本的 Docker（1.0 之后）也能提供基本的兼容。
