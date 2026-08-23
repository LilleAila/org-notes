{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default =
      with pkgs;
      mkShell {

        packages = [
          nixd
          nixfmt
          statix

          ruff
          pyright
        ];
      };
  };
}
