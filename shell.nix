{ pkgs ? import <nixpkgs> { }, android-nixpkgs ? import <android-nixpkgs> { } }:
with pkgs;
let 
    android-sdk =  android-nixpkgs.sdk.${system} (sdkPkgs: with sdkPkgs; [
            
            build-tools-35-0-0
            build-tools-34-0-0
            cmdline-tools-latest
            emulator
            platform-tools
            platforms-android-35
            platforms-android-34
          ]);
    dotnet-root="share/dotnet";
    # This is needed to install workload in $HOME
    # https://discourse.nixos.org/t/dotnet-maui-workload/20370/2
    userlocal =  ''
         for i in $out/${dotnet-root}/sdk/*; do
           i=$(basename $i)
           length=$(printf "%s" "$i" | wc -c)
           substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
           i="$substring""00"
           mkdir -p $out/${dotnet-root}/metadata/workloads/''${i/-*}
           touch $out/${dotnet-root}/metadata/workloads/''${i/-*}/userlocal
        done
      '';
    # append userlocal sctipt to postInstall phase
    postInstallUserlocal = (finalAttrs: previousAttrs: {
        postInstall = (previousAttrs.postInstall or '''') + userlocal;
    });
    # append userlocal sctipt to postBuild phase
    postBuildUserlocal = (finalAttrs: previousAttrs: {
        postBuild = (previousAttrs.postBuild or '''') + userlocal;
    });

    # use this if you don't need multiple SDK versions
    dotnet-combined = dotnetCorePackages.sdk_9_0.unwrapped.overrideAttrs postInstallUserlocal;
    
    # or use this if you ought to have multiple SDK versions
    # this will create userlocal files in both $DOTNET_ROOT and dotnet bin realtive path 
    # dotnet-combined = (with dotnetCorePackages; 
    #   combinePackages [
    #     (sdk_9_0.unwrapped.overrideAttrs postInstallUserlocal)
    #     (sdk_8_0.unwrapped.overrideAttrs postInstallUserlocal)
    #   ]).overrideAttrs postBuildUserlocal;

in mkShell {
  packages = [
      dotnet-combined
      tree
      android-sdk
      gradle
      jdk17
      aapt
      llvm_18
  ];
  DOTNET_ROOT = "${dotnet-combined}/${dotnet-root}";
  ANDROID_HOME = "${android-sdk}/share/android-sdk";
  ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
  JAVA_HOME = jdk17.home;
  NIX_LD_LIBRARY_PATH= pkgs.lib.makeLibraryPath [ 
      (lib.getLib pkgs.llvm_18)
      (lib.getLib pkgs.glibc)
    ];
  # make sure you have `programs.nix-ld.enable = true;` in your nixos config
  NIX_LD = pkgs.runCommand "ld.so" {} ''
    ln -s "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')" $out
  '';
}
