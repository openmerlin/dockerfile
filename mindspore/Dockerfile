ARG BASE_VERSION=latest
FROM ascendai/cann:${BASE_VERSION} as official

# Arguments
ARG MINDSPORE_VERSION=2.2.14

# Change the default shell
SHELL [ "/bin/bash", "-c" ]

# Install mindspore
RUN pip install --no-cache-dir \
        mindspore==${MINDSPORE_VERSION}
