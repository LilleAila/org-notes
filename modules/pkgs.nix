{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages = {
      tylax = pkgs.rustPlatform.buildRustPackage rec {
        pname = "tylax";
        version = "0.3.7";

        src = pkgs.fetchFromGitHub {
          owner = "scipenai";
          repo = "tylax";
          rev = "v${version}";
          hash = "sha256-XwgSBEJ0Y9Tuxivlizht7uGaRJMI45vZhaXZBVXxbTI=";
        };
        cargoHash = "sha256-AI1RXI1U7x7xU5GuzPsKpF3f5KeoXB7kYVxWITue9Xs=";

        meta = {
          mainProgram = "t2l";
        };
      };
    };
  };
}
