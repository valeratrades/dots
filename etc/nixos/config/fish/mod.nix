{ pkgs, ... }:

{
	programs.fish = {
		enable = true;
		package = pkgs.fish;
		shellInit = ''
			source "source (dirname (status --current-filename))/main.fish"
		'';
	};
}
