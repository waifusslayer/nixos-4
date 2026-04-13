{
  description = "Home Manager — DevOps userspace environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, krewfile, ... }@inputs:
  let
    mkHomeConfig = system:
    let
      username = builtins.getEnv "USER";
      homeDir  = builtins.getEnv "HOME";
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit inputs;
        inherit username homeDir;
      };
      modules = [
        ./home.nix
        { home.stateVersion = "25.05"; }
      ];
    };
  in {
    homeConfigurations = {
      "default"              = mkHomeConfig "x86_64-linux";
      "default@x86_64-linux"  = mkHomeConfig "x86_64-linux";
      "default@aarch64-linux" = mkHomeConfig "aarch64-linux";
      "default@x86_64-darwin" = mkHomeConfig "x86_64-darwin";
      "default@aarch64-darwin"= mkHomeConfig "aarch64-darwin";
    };
  };
}
