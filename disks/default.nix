{
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  impermanence ? false,
  lib,
  swap ? false,
  swapSize ? "4",
  ...
}: {
  disko = {
    devices = {
      disk = {
        main = lib.mkIf impermanence {
          inherit device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                size = "1M";
                type = "EF02";
              };
              esp = {
                name = "ESP";
                size = "500M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zimpermanence";
                };
              };
            };
          };
        };
        zfs = lib.mkIf (impermanence == false) {
          inherit device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                size = "1M";
                type = "EF02";
              };
              esp = {
                name = "ESP";
                size = "64M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              swap = lib.mkIf swap {
                size = "${swapSize}G";
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      zpool = {
        zroot = lib.mkIf impermanence {
          type = "zpool";
          rootFsOptions = {
            canmount = "off";
          };

          datasets = {
            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.mountpoint = "legacy";
            };
            tmp = {
              type = "zfs_fs";
              mountpoint = "/tmp";
              options.mountpoint = "legacy";
            };
            persist = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options.mountpoint = "legacy";
            };
            persist-cache = {
              type = "zfs_fs";
              mountpoint = "/persist/cache";
              options.mountpoint = "legacy";
            };
            disks = {
              type = "zfs_fs";
              mountpoint = "/disks";
              options.mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
