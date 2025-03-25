{
  imports = [
    (import ./_mkUser.nix "user")
  ];

  users.users.user = {
    uid = 10000;
    home = "/var/home/user";
    password = "123";
  };

  systemd.tmpfiles.rules = [
    "z /var/home 0755 root root - -"
  ];
}