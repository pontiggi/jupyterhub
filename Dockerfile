FROM centos:latest

COPY rc-all.repo /etc/yum.repos.d
COPY epel.repo /etc/yum.repos.d

RUN yum clean all && \
    rm -rf /var/cache/yum && \
    yum makecache fast &&  \
    yum -y  install slurm-devel slurm-slurmd slurm slurm-libpmi slurm-pam_slurm slurm-spank-x11  && \
    yum -y install wget git bzip2 sudo && \
    yum clean all && \
    rm -rf /var/cache/yum

# install Python + NodeJS with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.4.10-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo 'bec6203dbb2f53011e974e9bf4d46e93 */tmp/miniconda.sh' | md5sum -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes -c conda-forge \
      python=3.6 sqlalchemy tornado jinja2 traitlets requests pip pycurl \
      nodejs configurable-http-proxy && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

ADD . /src/jupyterhub
WORKDIR /src/jupyterhub

RUN pip install . && \
    rm -rf $PWD ~/.cache ~/.npm

RUN pip install batchspawner
RUN mkdir -p /srv/jupyterhub/
WORKDIR /srv/jupyterhub/
EXPOSE 8000

LABEL org.jupyter.service="jupyterhub"

CMD ["jupyterhub"]
