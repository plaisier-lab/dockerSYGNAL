FROM ubuntu:latest
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
MAINTAINER Chris Plaisier <plaisier@asu.edu>

RUN apt-get update

RUN apt-get install --yes software-properties-common

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9

RUN add-apt-repository "deb [trusted=yes] https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/"

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
 python \
 python-pip \
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
     #make test; \
     make install
ENV PATH /root/meme/bin:$PATH

# Install patched version of WEEDER 1.4.2
RUN git clone https://github.com/baliga-lab/weeder_patched.git
WORKDIR weeder_patched
RUN apt-get install --yes autoconf
RUN autoreconf -f -i
RUN ./configure
RUN make
RUN make install

# Install Python package dependencies
RUN pip install numpy scipy pandas biopython beautifulsoup4 SQLAlchemy SQLAlchemy-Utils svgwrite cherrypy Jinja2 Routes

# Install rpy
RUN pip install rpy2==2.8.6
    
# Install R packages needed to run SYGNAL
WORKDIR /
RUN R -e "install.packages(c('getopt','GeneCycle','GeneNet','ggm','sem','e1071','MASS','matrixStats','gplots','BiocManager'), repos = 'http://cran.us.r-project.org')"
# Bioconductor packages (impute, topGO)
RUN R -e "BiocManager::install(c('impute','topGO','preprocessCore','org.Hs.eg.db'))"
RUN R -e "install.packages(c('WGCNA'), repos = 'http://cran.us.r-project.org')"
RUN wget https://horvath.genetics.ucla.edu/html/aten/NEO/neoDecember2015.txt
RUN R -e "source('neoDecember2015.txt')"
