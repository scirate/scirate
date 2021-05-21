FROM nixos/nix
RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs \
    && nix-channel --update
WORKDIR /sciratetest
COPY ./shell.nix .
RUN nix-env -iA nixpkgs.git
RUN nix-shell shell.nix \
    && git clone https://github.com/scirate/scirate.git \
    && cd scirate \
    && rm Gemfile*
WORKDIR /sciratetest/scirate
COPY ./Gemfile ./

# OPTIONAL [Install packages directly]
#RUN bundle install && bundix
