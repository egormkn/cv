# syntax=docker/dockerfile:1

ARG TEXLIVE_VERSION=latest

FROM texlive/texlive:${TEXLIVE_VERSION} AS build

WORKDIR /workspace

COPY . .

RUN latexmk

FROM scratch

COPY --from=build /workspace/build/*.pdf /
