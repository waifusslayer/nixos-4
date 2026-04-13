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
    mkHomeConfig = system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home.nix
        { home.stateVersion = "25.05"; }
      ];
    };

    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  in {
    # Запуск: home-manager switch --flake .#default
    # Читает $USER и $HOME автоматически из окружения
    homeConfigurations = nixpkgs.lib.genAttrs systems (system: mkHomeConfig system) //
      { default = mkHomeConfig "x86_64-linux"; };
  };
}
