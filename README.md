Example of nixos shell for dotnet-android / MAUI with userspace workloads 
```
git clone https://github.com/anpin/maui-on-nix
cd maui-on-nix
nix develop 
dotnet workload restore 
dotnet build
```
