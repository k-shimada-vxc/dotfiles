{
  description = "k-shimada macOS environment managed with nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inspired-mino-design-skills = {
      url = "github:my-take-dev/inspired-mino-design-skills";
      flake = false;
    };
  };

  outputs =
    {
      nix-darwin,
      home-manager,
      inspired-mino-design-skills,
      ...
    }:
    let
      username = "k-shimada";
      homeDirectory = "/Users/${username}";
    in
    {
      darwinConfigurations."VX-NT-0969" = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit username homeDirectory;
        };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit username homeDirectory inspired-mino-design-skills;
              };
              users.${username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
