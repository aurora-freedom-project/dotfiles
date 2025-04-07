{ config, pkgs, ... }:

{
  # Module cho ảo hóa trên NixOS
  
  # Cấu hình KVM/QEMU
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
      };
    };
    
    # Cấu hình Docker
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    
    # Cấu hình Podman
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    # Cấu hình LXD
    lxd.enable = true;
  };
  
  # Cấu hình nhóm người dùng
  users.groups.libvirtd.members = [ "rnd" ];
  users.groups.docker.members = [ "rnd" ];
  
  # Cấu hình các gói phần mềm liên quan
  environment.systemPackages = with pkgs; [
    # Các công cụ ảo hóa
    virt-manager
    virt-viewer
    spice-gtk
    win-virtio
    swtpm
    
    # Các công cụ container
    docker-compose
    lazydocker
    dive
  ];
  
  # Cấu hình tường lửa
  networking.firewall = {
    allowedTCPPorts = [ 2376 ];
    trustedInterfaces = [ "virbr0" "docker0" ];
  };
}
