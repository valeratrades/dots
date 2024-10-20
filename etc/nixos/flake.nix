{
	description = "OS master";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		#naersk.url = "https://github.com/nix-community/naersk/master";
	};

	outputs = inputs@{ self, nixpkgs, ... }: {
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
			];
		};
	};
}
