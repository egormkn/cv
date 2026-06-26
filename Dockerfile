# syntax=docker/dockerfile:1

ARG TEXLIVE_VERSION=latest

ARG PDF2HTMLEX_VERSION=0.18.8.rc2-master-20200820-ubuntu-20.04-x86_64

FROM texlive/texlive:${TEXLIVE_VERSION} AS build_pdf

WORKDIR /workspace

COPY . .

RUN latexmk

FROM pdf2htmlex/pdf2htmlex:${PDF2HTMLEX_VERSION} AS build_html

RUN apt-get update && apt-get install -y \
  patch \
  ttfautohint \
  && rm -rf /var/lib/apt/lists/*

COPY ./third_party/pdf2htmlEX/* /usr/local/share/pdf2htmlEX/

RUN patch /usr/local/share/pdf2htmlEX/manifest < /usr/local/share/pdf2htmlEX/manifest.patch

WORKDIR /workspace

COPY --from=build_pdf /workspace/build/*.pdf /workspace/

RUN <<EOF
mkdir build
for FILE in *.pdf; do
  OUTPUT_FILE="$(basename "${FILE/%.pdf}.html")"
  pdf2htmlEX \
    --process-outline 0 \
    --dest-dir build \
    --bg-format svg \
    --external-hint-tool ttfautohint \
    "$FILE" "$OUTPUT_FILE"
done
EOF


FROM scratch

COPY --from=build_pdf /workspace/build/*.pdf /

COPY --from=build_html /workspace/build/*.html /
