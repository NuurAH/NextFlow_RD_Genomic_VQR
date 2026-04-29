# Use the continuumio/miniconda3 base image
FROM continuumio/miniconda3:26.1.1

RUN conda init bash && \
    echo "conda activate base" > ~/.bashrc && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda install -y  \
        glnexus==1.4.1 \
        bcftools==1.21 && \
    conda clean --all -f -y


# Metadata indicating the author or maintainer of the image
LABEL maintainer="Harbi Nuur <Harbi.Nuur@postgrad.manchester.ac.uk>"
# Metadata about the purpose or description of the image
LABEL description="Docker image containing gl-nexus==1.4.1 and bcftools==1.21"

# Default command to run when the container starts
CMD ["glnexus_cli", "-l"]
