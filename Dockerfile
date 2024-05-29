# Use the official Ubuntu image as a base
FROM ubuntu:20.04

# Set environment variables
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/usr/local/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install necessary packages
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget ssh rsync && \
    apt-get clean

# Create hadoop user and group
RUN groupadd hadoop && \
    useradd -g hadoop -m -s /bin/bash hadoop && \
    echo 'hadoop:hadoop' | chpasswd && \
    adduser hadoop sudo

# Download and extract Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -xzvf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/local/hadoop && \
    rm hadoop-$HADOOP_VERSION.tar.gz && \
    chown -R hadoop:hadoop /usr/local/hadoop

# Configure SSH
RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chown -R hadoop:hadoop /root/.ssh

# Create SSH directory with correct permissions
RUN mkdir -p /run/sshd && chmod 0755 /run/sshd && chown root:root /run/sshd

# Copy Hadoop configuration files
COPY config/* $HADOOP_HOME/etc/hadoop/

# Set permissions
RUN chmod +x $HADOOP_HOME/etc/hadoop/*.sh && \
    chown -R hadoop:hadoop $HADOOP_HOME/etc/hadoop

# Switch to hadoop user
USER hadoop
WORKDIR /home/hadoop

# Start SSH service and keep the container running
CMD ["bash", "-c", "service ssh start && tail -f /dev/null"]
