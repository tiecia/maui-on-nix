{
  description = "basic dotnet MAUI shell";
  
  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=master";
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
