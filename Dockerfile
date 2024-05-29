FROM nixos/nix:latest
RUN git clone https://github.com/anpin/maui-on-nix
WORKDIR /maui-on-nix
RUN nix --extra-experimental-features "nix-command flakes" develop --command bash -c "\
    dotnet workload restore -v detailed && \
    dotnet restore -v detailed && \
    dotnet build -v detailed"


