FROM bitnami/minideb:jessie

#####EXTRA LABELS#####
LABEL autogen="no" \ 
    software="CESM" \ 
    version="2" \
    software.version="2.1.1" \ 
    about.summary="Community Earth System Model" \ 
    base_image="cesm:2.1.1--py37he9b5208_1" \
    about.home="VR-CESM" \
    about.license="Copyright (c) 2017, University Corporation for Atmospheric Research (UCAR). All rights reserved." 
      
MAINTAINER Anne Fouilloux <annefou@geo.uio.no>

# By default en_US.UTF-8 is not generated, and locale-gen is not installed
# (comes with locales)
# and uncomment the en_US.UTF-8 line from /etc/locale.gen and regenerate
# AF: added svn, csh and wget for CESM B1850 configuration (with ocean)
RUN install_packages libgl1-mesa-glx locales openssh-client procps \
    vim csh wget bzip2 ca-certificates curl git subversion && \
    sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && locale-gen

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Install miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -u -p /usr/local && \
    rm ~/miniconda.sh && \
    /usr/local/bin/conda config --add channels defaults && \
    /usr/local/bin/conda config --add channels bioconda && \ 
    /usr/local/bin/conda config --add channels conda-forge && \
    /usr/local/bin/conda install cesm && \
    /usr/local/bin/conda clean -tipsy && \
    ln -s /usr/local/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /usr/local/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN ln -s /usr/local/bin/x86_64-conda_cos6-linux-gnu-ar /usr/local/bin/ar


RUN adduser cesm --disabled-password && usermod -aG users cesm

USER cesm

RUN mkdir -p /home/cesm/.cime \
             /home/cesm/packages \
             /home/cesm/work \
             /home/cesm/inputdata \
             /home/cesm/archive \
             /home/cesm/cases 

COPY config_files/* /home/cesm/.cime/

ENV AR=ar

ENV USER=cesm

WORKDIR /home/cesm

COPY run_noresm /home/cesm/

ENTRYPOINT ./run_noresm

#CMD ["/bin/bash"]

