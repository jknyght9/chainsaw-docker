# Chainsaw in Docker

FROM alpine:latest AS stage

ARG CHAINSAW_VERSION="v2.7.3"
ARG CHAINSAW_URL="https://github.com/WithSecureLabs/chainsaw/releases/download/${CHAINSAW_VERSION}/chainsaw_all_platforms+rules+examples.zip"
ARG SIGMA_URL="https://github.com/SigmaHQ/sigma/archive/refs/heads/master.zip"

RUN apk update
RUN apk add --no-cache --virtual=stage \
    7zip \
    curl \
    python3-dev

WORKDIR /stage

# Install Chainsaw
RUN curl -Lo chainsaw.zip "${CHAINSAW_URL}"
RUN wget -O chainsaw.zip "${CHAINSAW_URL}"
RUN 7z x chainsaw.zip
RUN cd chainsaw && \
    mv chainsaw_x86_64-unknown-linux-mus chainsaw && \
    chmod 777 chainsaw && \
    rm LICENCE README.md chainsaw_x86*

WORKDIR /stage/chainsaw

# Install Sigma rules from Git repo
RUN curl -Lo sigma-master.zip "${SIGMA_URL}" && \
    7z x sigma-master.zip && \
    rm -rf ./sigma && \
    mv sigma-master sigma && \
    rm sigma-master.zip

# Install Valhalla Community Sigma Rules
RUN python3 -m ensurepip --default-pip && \
    python3 -m pip install --no-cache --upgrade valhallaAPI
RUN /usr/bin/valhalla-cli -k "1111111111111111111111111111111111111111111111111111111111111111" -s
RUN 7z x valhalla-rules.zip -orules-valhalla && \
    mv rules-valhalla sigma && \
    rm valhalla-rules.zip 

RUN apk --purge del \
    stage

FROM alpine:latest as production

ARG INSTALL_PREFIX="/usr/local"

WORKDIR "${INSTALL_PREFIX}/lib"

COPY --from=stage \
    /stage/chainsaw \
    chainsaw

WORKDIR "${INSTALL_PREFIX}/lib/chainsaw"

RUN apk add --no-cache \
    dumb-init

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/usr/local/lib/chainsaw/chainsaw" ]
CMD [ "-h" ]

ARG PRODUCT_AUTHOR="Jacob Stauffer <jdstauffer@proton.me"
ARG PRODUCT_REPOSITORY=""
ARG PRODUCT_BUILD_DATE="-"
ARG PRODUCT_BUILD_COMMIT="-"

LABEL image.author="${PRODUCT_AUTHOR}"
LABEL image.commit="${PRODUCT_BUILD_COMMIT}"
LABEL image.date="${PRODUCT_BUILD_DATE}"
LABEL image.repository="${PRODUCT_REPOSITORY}"