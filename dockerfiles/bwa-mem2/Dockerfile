# Use the continuumio/miniconda3 base image
FROM continuumio/miniconda3:26.1.1

RUN conda install -y mamba=2.5.0 -n base -c conda-forge &&\
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    mamba install -y  \
        bwa-mem2==2.3 \
        samtools==1.23 \
        procps-ng==4.0.6 \
        picard==3.4.0 && \
    conda clean -afy



# Metadata indicating the author or maintainer of the image
LABEL maintainer="Harbi Nuur <Harbi.Nuur@postgrad.manchester.ac.uk>"
# Metadata about the purpose or description of the image
LABEL description="Docker image containing bwa-mem2==2.3, samtools==1.23, procps-ng==4.0.6 and picard==3.4.0"

# Default command to run when the container starts
CMD ["/bin/bash"]
