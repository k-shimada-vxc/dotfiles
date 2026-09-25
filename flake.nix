{
  description = "k-shimada macOS environment managed with nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # 更新の速い CLI だけを追従させるため、安定版とは別に unstable を持つ。
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    gh-stack = {
      url = "github:github/gh-stack";
      flake = false;
    };
    pr-lens = {
      url = "github:coldteadotai/pr-lens";
      flake = false;
    };
    humanlayer-skills = {
      url = "github:humanlayer/skills";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      inspired-mino-design-skills,
      gh-stack,
      pr-lens,
      humanlayer-skills,
      ...
    }:
    let
      username = "k-shimada";
      homeDirectory = "/Users/${username}";
      pkgs-unstable = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs-unstable.lib.getName pkg) [
            "claude-code"
          ];
      };
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
                inherit
                  username
                  homeDirectory
                  pkgs-unstable
                  inspired-mino-design-skills
                  gh-stack
                  pr-lens
                  humanlayer-skills
                  ;
              };
              users.${username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
