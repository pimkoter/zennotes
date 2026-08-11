{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.zennotes;
in
{
  options.services.zennotes = {
    enable = lib.mkEnableOption "ZenNotes self-hosted server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package-server.nix { };
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/zennotes";
    };

    vaultPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/zennotes/vault";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7878;
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.zennotes = {
      isSystemUser = true;
      group = "zennotes";
      home = cfg.dataDir;
    };

    users.groups.zennotes = { };

    systemd.services.zennotes = {
      description = "ZenNotes Self-Hosted Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";

        User = "zennotes";
        Group = "zennotes";

        WorkingDirectory = cfg.dataDir;

        ExecStart = "${cfg.package}/bin/zennotes-server";

        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "zennotes";

        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;

        ReadWritePaths = [
          cfg.dataDir
          cfg.vaultPath
        ];
      };

      environment = {
        PORT = toString cfg.port;
        ZENNOTES_AUTH_TOKEN = "12345";
      }
      // cfg.extraEnvironment;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
