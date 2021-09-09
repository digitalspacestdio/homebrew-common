FROM digitalspacestudio/linuxbrew:3.2.8 as builder
LABEL maintainer="Sergey Cherepanov <s@cherepanov.co>"
LABEL name="djocker/elasticsearch76"
ARG DEBIAN_FRONTEND=noninteractive
ARG BREW_FORMULA=elasticsearch@7.6

USER root
RUN apt update && apt install libx11-dev

USER linuxbrew
RUN brew tap djocker/common

RUN brew install --only-dependencies ${BREW_FORMULA}
RUN brew install ${BREW_FORMULA}

# Cleanup
RUN rm -rf /home/linuxbrew/.cache/Homebrew \
    && brew cleanup \
    && rm -rf /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby

FROM digitalspacestudio/debian
RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
WORKDIR /home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    SHELL=/bin/bash \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1
COPY --from=builder --chown=linuxbrew:linuxbrew /home/linuxbrew /home/linuxbrew
