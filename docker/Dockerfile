from scratch

# Add the file system.
ADD filesystem /
ADD iso /iso
ADD toiso /toiso

# Set environment variables.
ENV HOME /root
ENV PATH /root/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/bin/bash"]

# Install packages for iso creation.
RUN apt-get update && \
    apt-get -qq -y install squashfs-tools && \
    apt-get clean

RUN /toiso/clean_up.sh
