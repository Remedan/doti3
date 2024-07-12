{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      nixosConfigurations = {
        weatherwax = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/weatherwax/system.nix
          ] ++ import ./modules/system;
        };

        rincewind = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/rincewind/system.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-yoga
          ] ++ import ./modules/system;
        };

        atuin = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/atuin/system.nix
            ./secrets/atuin-system.nix
            nixos-hardware.nixosModules.dell-latitude-5520
          ] ++ import ./modules/system;
        };
      };

      homeConfigurations = {
        "remedan@weatherwax" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (import ./hosts/weatherwax/user.nix)
            (import ./secrets/weatherwax-user.nix)
          ] ++ import ./modules/user;
        };

        "remedan@rincewind" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (import ./hosts/rincewind/user.nix)
          ] ++ import ./modules/user;
        };

        "vojta@atuin" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (import ./hosts/atuin/user.nix)
            (import ./secrets/atuin-user.nix)
          ] ++ import ./modules/user;
        };
      };
    };
}
