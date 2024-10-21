{
	description = "OS master";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager/release-24.05";
			# The `follows` keyword in inputs is used for inheritance.
			# Here, `inputs.nixpkgs` of home-manager is kept consistent with
			# the `inputs.nixpkgs` of the current flake,
			# to avoid problems caused by different versions of nixpkgs.
			inputs.nixpkgs.follows = "nixpkgs";
		};

		#naersk.url = "https://github.com/nix-community/naersk/master";
	};

	outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
		# from https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-flake-and-module-system 
		#nix.registry.nixpkgs.flake = nixpkgs;
		#nix.channel.enable = false;
		#environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
		#nix.settings.nix-path = nixpkgs.lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";

		nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";

			specialArgs = { inherit inputs; };
			modules = [
				./configuration.nix

				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.backupFileExtension = "hm-backup";

					home-manager.users.v = import ./home.nix;
				}
			];
		};
	};
}
