{ config, pkgs, ... }:

{
  # Module cho hỗ trợ NVIDIA trên NixOS
  
  # Cấu hình driver NVIDIA
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # Cấu hình driver NVIDIA
  hardware.nvidia = {
    # Sử dụng driver mới nhất
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Bật modesetting
    modesetting.enable = true;
    
    # Cấu hình Prime (cho laptop có cả Intel và NVIDIA)
    prime = {
      # Uncomment dòng dưới đây nếu sử dụng laptop có cả Intel và NVIDIA
      # intelBusId = "PCI:0:2:0";
      # nvidiaBusId = "PCI:1:0:0";
      
      # Chọn một trong các chế độ sau:
      # offload: Chỉ sử dụng NVIDIA khi cần thiết
      # sync: Luôn sử dụng NVIDIA
      # none: Chỉ sử dụng NVIDIA
      # offload.enable = true;
      # sync.enable = true;
    };
    
    # Cấu hình PowerManagement
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    
    # Cấu hình các tùy chọn khác
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
  };
  
  # Cấu hình kernel parameters
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  
  # Cấu hình các gói phần mềm liên quan
  environment.systemPackages = with pkgs; [
    # Các công cụ NVIDIA
    nvidia-settings
    nvtop
    glxinfo
  ];
}
