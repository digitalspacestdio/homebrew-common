FROM djocker/linuxbrew as builder
LABEL maintainer="Sergey Cherepanov <s@cherepanov.co>"
LABEL name="djocker/mongodb36"
ARG DEBIAN_FRONTEND=noninteractive
ARG BREW_FORMULA=mongodb36
ARG HOMEBREW_NO_INSTALL_CLEANUP=1
ARG HOMEBREW_NO_AUTO_UPDATE=1

RUN brew update
RUN brew tap djocker/common

RUN brew install --only-dependencies ${BREW_FORMULA}
RUN brew install ${BREW_FORMULA}

# Cleanup
RUN rm -rf /home/linuxbrew/.cache/Homebrew \
    && brew cleanup \
    && rm -rf /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby

FROM djocker/debian
RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
WORKDIR /home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    SHELL=/bin/bash \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1
COPY --from=builder --chown=linuxbrew:linuxbrew /home/linuxbrew /home/linuxbrew