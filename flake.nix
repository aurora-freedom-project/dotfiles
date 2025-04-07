{
  description = "Aurora Freedom Project Dotfiles";

  inputs = {
    # Nixpkgs
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Nix-darwin for macOS
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-darwin, home-manager, darwin, ... }@inputs:
    let
      # Supported systems
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Nixpkgs instantiated for supported systems with allowUnfree enabled
      nixpkgsFor = forAllSystems (system: import nixpkgs { 
        inherit system; 
        config = { allowUnfree = true; };
      });
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        # Legion laptop configuration
        legion = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nixos/legion
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rnd = import ./home/profiles/rnd;
            }
          ];
        };
        
        # WSL configuration
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nixos/wsl
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.rnd = import ./home/profiles/rnd;
            }
          ];
        };
      };
      
      # Darwin (macOS) configurations
      darwinConfigurations = {
        # MacBook configuration
        macbook = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/darwin/macbook
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mike = import ./home/profiles/mike;
              # Add allowUnfree configuration for Darwin
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };
      };
      
      # Home-manager standalone configurations for non-NixOS Linux (Ubuntu)
      homeConfigurations = {
        "rnd@ubuntu" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor."x86_64-linux";
          modules = [
            ./home/linux.nix
            ./home/profiles/rnd
          ];
        };
        
        # Thêm cấu hình cho "mike@ubuntu" nếu cần
        "mike@ubuntu" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor."x86_64-linux";
          modules = [
            ./home/linux.nix
            ./home/profiles/mike
          ];
        };
      };
      
      # Development shells
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              nil
            ];
          };
        }
      );
    };
}
