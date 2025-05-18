FROM registry.fedoraproject.org/fedora-minimal:40

RUN sed -i '/\[main\]/a tsflags=nodocs' /etc/dnf/dnf.conf
RUN sed -i '/\[main\]/a install_weak_deps=False' /etc/dnf/dnf.conf

RUN microdnf install -y procps-ng bind-utils iputils which iproute && microdnf clean all

RUN microdnf install -y \
  neovim python3-neovim \
  fd-find fzf nodejs20-npm ripgrep wget curl zip \
  tar gitlint git gcc gcc-c++ python3-pip golang xsel \
  cargo julia zstd tree-sitter-cli nodejs vim-minimal && microdnf clean all

RUN useradd -ms /bin/bash -e $(date -I) -G wheel nyoom
RUN sed -i '/^#auth/s/^#//g' /etc/pam.d/su

RUN microdnf -y swap glibc-minimal-langpack glibc-langpack-en && microdnf clean all
RUN microdnf -y upgrade && microdnf clean all
ENV LANG=us_EN.UTF-8
ENV CONTAINER_NAME=nyoom-container

#USER nyoom
COPY setup.sh /

CMD [ "bash" ]
