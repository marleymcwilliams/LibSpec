# Optional: reproducible LaTeX + Python toolchain
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    make git python3 python3-pip \
    texlive-full latexmk chktex \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY . /work
RUN pip3 install --no-cache-dir jsonschema codespell mkdocs mkdocs-material

CMD ["bash"]
