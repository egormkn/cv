# syntax=docker/dockerfile:1

FROM texlive/texlive:latest AS build

WORKDIR /src

COPY . .

RUN latexmk

FROM scratch

COPY --from=build /src/build/*.pdf /
