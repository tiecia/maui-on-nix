{
  description = "basic dotnet MAUI shell";
  
  inputs = {

    nixpkgs = {
      # url = "github:nixos/nixpkgs?rev=6bed24773e134d7427a48cfdb856665f5f4b3c05";


      # url = "github:nixos/nixpkgs?rev=ddd08e404f21d39ae6592ae359f416e7b0fd8462";
      url = "github:nixos/nixpkgs?rev=42d69ab59a80edf0c79b112f7a9b6dd86858c2cd";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, android-nixpkgs , ... }:
    let 
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system ; };
    inherit (inputs.nixpkgs) lib; 
    in {
      
      devShells.${system}.default = import ./shell.nix {inherit pkgs  android-nixpkgs; };

  };
}
