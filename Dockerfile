# syntax=docker/dockerfile:1

ARG TEXLIVE_VERSION=latest

ARG PDF2HTMLEX_VERSION=0.18.8.rc2-master-20200820-ubuntu-20.04-x86_64

FROM texlive/texlive:${TEXLIVE_VERSION} AS build_pdf

WORKDIR /workspace

COPY . .

RUN latexmk

FROM pdf2htmlex/pdf2htmlex:${PDF2HTMLEX_VERSION} AS build_html

RUN apt-get update && apt-get install -y \
  ttfautohint \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY --from=build_pdf /workspace/build/*.pdf /workspace/

RUN mkdir build && \
    find . -type f -name "*.pdf" -exec \
      pdf2htmlEX \
        --process-outline 0 \
        --dest-dir build \
        --bg-format svg \
        --external-hint-tool ttfautohint \
        {} \;

FROM scratch

COPY --from=build_pdf /workspace/build/*.pdf /

COPY --from=build_html /workspace/build/*.html /
