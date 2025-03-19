ARG BASE_VERSION=latest
FROM ascendai/cann:${BASE_VERSION} as official

# Arguments
ARG MINDSPORE_VERSION=2.4.0
# Change the default shell
SHELL [ "/bin/bash", "-c" ]

# Install mindspore
RUN pip install --no-cache-dir \
        mindspore==${MINDSPORE_VERSION}