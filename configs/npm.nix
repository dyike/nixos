{ config, lib, ... }:
let
  user = "yuanfeng";
  userCfg = config.users.users.${user};
  homeDir = if userCfg ? home then userCfg.home else "/home/${user}";
  userGroup = if userCfg ? group then userCfg.group else user;
  npmPrefix = "${homeDir}/.local";
  npmEnv = {
    NPM_CONFIG_PREFIX = npmPrefix;
    npm_config_prefix = npmPrefix;
    NPM_CONFIG_GLOBALCONFIG = "/etc/npmrc";
    npm_config_globalconfig = "/etc/npmrc";
  };
in {
  environment.sessionVariables = npmEnv;
  environment.variables = npmEnv;

  environment.etc."npmrc".text = ''
    prefix = ${npmPrefix}
  '';

  environment.extraInit = lib.mkAfter ''
    export PATH="${npmPrefix}/bin:$PATH"
  '';

  systemd.tmpfiles.rules = [
    "d ${npmPrefix} 0755 ${user} ${userGroup} -"
    "d ${npmPrefix}/bin 0755 ${user} ${userGroup} -"
    "d ${npmPrefix}/lib 0755 ${user} ${userGroup} -"
    "d ${npmPrefix}/lib/node_modules 0755 ${user} ${userGroup} -"
  ];
}
