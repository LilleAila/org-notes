{ self, lib, ... }: {
  perSystem =
    { pkgs, ... }:
    let
      pkgs' = self.outputs.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      apps = rec {
        default = publish;
        publish = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "publish" ''
              set -euo pipefail
              ${lib.getExe pkgs'.org-publish}
              ${lib.getExe pkgs'.sync-db} 'org' 'org/org-roam.db'
            ''
          );
        };
      };
    };
}
