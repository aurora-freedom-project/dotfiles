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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    
    # Nix-darwin for macOS
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-darwin, home-manager, darwin, ... }@inputs:
    let
      traceImport = true;
      # Supported systems
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Nixpkgs instantiated for supported systems with allowUnfree enabled
      nixpkgsFor = forAllSystems (system: import nixpkgs { 
        inherit system; 
        config = { allowUnfree = true; };
      });
      
      # Get all user profiles from the profiles directory
      getUserProfiles = dir:
        let
          profilesDir = dir + "/home/profiles";
          contents = builtins.readDir profilesDir;
          # Fix: Use nixpkgs.lib.filterAttrs instead of builtins.filterAttrs
          dirNames = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory" && n != "template") contents);
        in
          dirNames;
          
      # Helper function to create Darwin configurations for all users
      mkAllDarwinConfigs = dir:
        let
          users = getUserProfiles dir;
          mkConfig = username: {
            name = "macbook-${username}";
            value = mkDarwinSystem {
              hostname = "macbook-${username}";
              username = username;
            };
          };
        in
          # Make sure this returns an empty set if no users are found
          if users == [] then {} else builtins.listToAttrs (map mkConfig users);
      
      # Helper function to create Darwin configurations
      mkDarwinSystem = { hostname, username, system ? "x86_64-darwin" }: 
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./hosts/darwin/macbook
            ./modules/shared
            ./modules/darwin
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/profiles/${username};
              nixpkgs.config.allowUnfree = true;
            } 
          ];
        };
      
      # Helper function to create NixOS configurations
      mkNixosSystem = { hostname, username, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nixos/${hostname}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/profiles/${username};
              nixpkgs.config.allowUnfree = true;
            }  
          ];
        };
      
      # Helper function to create Home Manager configurations
      mkHomeConfig = { username, hostname, system ? "x86_64-linux" }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.${system};
          modules = [
            ./home/linux.nix
            ./home/profiles/${username}
          ];
        };
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
              nixpkgs-unstable.config.allowUnfree = true;
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
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };
      };
      
      # Darwin (macOS) configurations - more dynamic approach
      darwinConfigurations = 
        # Add static configurations
        {
          # Default macbook configuration
          macbook = mkDarwinSystem { 
            hostname = "macbook"; 
            username = "mike";
          };
        } 
        # Merge with dynamically generated configurations
        // mkAllDarwinConfigs ./.;
      
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
