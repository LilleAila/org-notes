{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      basePackage = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs else pkgs.emacs-pgtk;
      emacsPackages = pkgs.emacsPackagesFor basePackage;
      emacsPackage = emacsPackages.emacsWithPackages (
        epkgs: with epkgs; [
          org
          magit
          org-roam
        ]
      );
    in
    {
      packages.sync-db = pkgs.writeShellApplication {
        name = "sync-db";
        runtimeInputs = [ emacsPackage ];
        text = ''
          emacs --batch -l ${./sync-db.el} "$@"
        '';
      };
    };
}
