FROM ubuntu:latest
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
MAINTAINER Chris Plaisier <plaisier@asu.edu>
RUN apt-get update

# Turn off interactive installation features
ENV DEBIAN_FRONTEND=noninteractive

# Prepare Ubuntu by installing necessary dependencies
RUN apt-get install --yes \
 build-essential \
 gcc-multilib \
 apt-utils \
 zlib1g-dev \
 vim-common \
 wget \
 python3 \
 python3-pip \
 git \
 pigz \
 r-base \
 r-base-dev \
 libxml2 \
 libxml2-dev

# Install MEME
RUN apt-get install curl -y
RUN curl http://meme-suite.org/meme-software/4.11.3/meme_4.11.3_1.tar.gz meme_4.11.3_1.tar.gz | tar zx
RUN cd meme_4.11.3 && \
     ./configure --prefix=$HOME/meme \
        --with-url=http://meme-suite.org \
        --enable-build-libxml2 \
        --enable-build-libxslt \
        --with-python=/usr/bin/python; \
     make; \
     make test; \
     make install
ENV PATH /root/meme/bin:$PATH

# Install patched version of WEEDER 1.4.2
RUN git clone https://github.com/baliga-lab/weeder_patched.git
WORKDIR weeder_patched
RUN ./configure
RUN make
RUN make install

# Install rpy
RUN pip3 install rpy2

# Install R packages needed to run SYGNAL
WORKDIR /
RUN R -e "install.packages(c('getopt','GeneCycle','GeneNet','ggm','sem','e1071','MASS','matrixStats','gplots','BiocManager'), repos = 'http://cran.us.r-project.org')"
# Bioconductor packages (impute, topGO)
RUN R -e "BiocManager::install(c('impute','topGO'))"
RUN R -e "install.packages(c('WGCNA'), repos = 'http://cran.us.r-project.org')"
RUN wget https://horvath.genetics.ucla.edu/html/aten/NEO/neoDecember2015.txt
RUN R -e "source('neoDecember2015.txt')"

# Install cMonkey2
RUN pip3 install cmonkey2
