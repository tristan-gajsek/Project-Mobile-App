{
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

      androidSdk =
        (pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [
            "30.0.3"
            "33.0.1"
            "34.0.0"
          ];
          platformVersions = [
            "30"
            "31"
            "33"
            "34"
            "35"
          ];
        }).androidsdk;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        shellHook = "exec zsh";
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        buildInputs = with pkgs; [
          flutter
          androidSdk
          jdk17
        ];
      };
    };
}
