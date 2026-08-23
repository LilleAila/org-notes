{ self, lib, ... }: {
  perSystem = { pkgs, ... }: {
    packages.org-publish =
      let
        pkgs' = self.packages.${pkgs.stdenv.hostPlatform.system};
        pythonPackage = pkgs.python3.withPackages (ps: with ps; [ ]);
        runtimeDependencies = with pkgs; [
          typst
          pkgs'.tylax
        ];
      in
      pkgs.stdenv.mkDerivation {
        pname = "org-publish";
        version = "0.1.0";
        src = ./.;

        buildInputs = [ pythonPackage ] ++ runtimeDependencies;
        nativeBuildInputs = with pkgs; [ makeWrapper ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          mkdir -p $out/share/org-publish
          cp -r ./* $out/share/org-publish
          makeWrapper ${lib.getExe pythonPackage} $out/bin/org-publish \
            --add-flags "$out/share/org-publish/main.py" \
            --prefix PATH : ${lib.makeBinPath runtimeDependencies}
          runHook postInstall
        '';

        meta.mainProgram = "org-publish";
      };
  };
}
