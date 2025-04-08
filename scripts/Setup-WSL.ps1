# Setup-WSL.ps1 - Script tự động thiết lập và cấu hình cho Windows/WSL
# Phần của Aurora Freedom Project Dotfiles

# Hàm hiển thị thông báo
function Write-Message {
    param (
        [string]$Message,
        [string]$Type = "Info"
    )
    
    switch ($Type) {
        "Info" { 
            Write-Host "==> $Message" -ForegroundColor Blue 
        }
        "Success" { 
            Write-Host "==> $Message" -ForegroundColor Green 
        }
        "Warning" { 
            Write-Host "==> $Message" -ForegroundColor Yellow 
        }
        "Error" { 
            Write-Host "==> $Message" -ForegroundColor Red 
        }
    }
}

# Kiểm tra quyền admin
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $user
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Kiểm tra và bật tính năng WSL
function Enable-WSL {
    Write-Message "Kiểm tra tính năng WSL..."
    
    $wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    
    if ($wslenabled.State -ne "Enabled") {
        Write-Message "Đang bật tính năng WSL..." "Info"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        
        $vmpenabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
        
        if ($vmpenabled.State -ne "Enabled") {
            Write-Message "Đang bật tính năng Virtual Machine Platform..." "Info"
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        }
        
        Write-Message "Cần khởi động lại máy tính để hoàn tất cài đặt WSL. Vui lòng khởi động lại và chạy lại script này." "Warning"
        return $false
    }
    
    Write-Message "WSL đã được bật!" "Success"
    return $true
}

# Cài đặt WSL2 Linux kernel update
function Install-WSL2Kernel {
    Write-Message "Kiểm tra WSL2 Linux kernel..."
    
    # Kiểm tra phiên bản WSL
    $wslVersion = wsl --status | Select-String -Pattern "Default Version"
    
    if (-not $wslVersion -or $wslVersion -notmatch "2") {
        Write-Message "Đang tải WSL2 Linux kernel update package..." "Info"
        $kernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $kernelInstaller = "$env:TEMP\wsl_update_x64.msi"
        
        Invoke-WebRequest -Uri $kernelUrl -OutFile $kernelInstaller
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$kernelInstaller`" /quiet" -Wait
        
        # Đặt WSL2 làm mặc định
        wsl --set-default-version 2
        
        Write-Message "Đã cài đặt WSL2 Linux kernel update!" "Success"
    } else {
        Write-Message "WSL2 đã được cài đặt!" "Success"
    }
}

# Clone repository dotfiles
function Clone-Dotfiles {
    param (
        [string]$Distro
    )
    
    Write-Message "Chuẩn bị clone repository dotfiles..." "Info"
    
    # Tạo script bash để clone repository trên distro
    $cloneScript = @"
#!/bin/bash
# Clone repository dotfiles

DOTFILES_DIR="\$HOME/aurora-dotfiles"

if [ -d "\$DOTFILES_DIR" ]; then
    echo "Repository dotfiles đã tồn tại. Đang cập nhật..."
    cd "\$DOTFILES_DIR"
    git pull
else
    echo "Đang clone repository dotfiles..."
    git clone https://github.com/aurora-freedom-project/dotfiles.git "\$DOTFILES_DIR"
fi

echo "Repository dotfiles đã sẵn sàng!"

# Tạo thư mục .config/nixpkgs nếu chưa tồn tại
mkdir -p "\$HOME/.config/nixpkgs"

# Sao chép các file cấu hình từ repository vào .config/nixpkgs
echo "Đang sao chép các file cấu hình..."
cp -r "\$DOTFILES_DIR"/* "\$HOME/.config/nixpkgs/"

echo "Đã sao chép các file cấu hình!"
"@
    
    # Lưu script vào file tạm thời
    $tempScript = "$env:TEMP\clone-dotfiles.sh"
    $cloneScript | Out-File -FilePath $tempScript -Encoding ASCII
    
    # Chạy script trên distro
    Write-Message "Đang clone repository dotfiles trên $Distro..." "Info"
    wsl -d $Distro bash -c "cat > ~/clone-dotfiles.sh && chmod +x ~/clone-dotfiles.sh && ~/clone-dotfiles.sh" < $tempScript
    
    Write-Message "Repository dotfiles đã được clone và cài đặt trên $Distro!" "Success"
}

# Cài đặt Ubuntu hoặc NixOS trên WSL
function Install-LinuxDistro {
    param (
        [string]$Distro
    )
    
    if ($Distro -eq "Ubuntu") {
        Write-Message "Kiểm tra Ubuntu trên WSL..." "Info"
        
        $ubuntuInstalled = wsl --list | Select-String -Pattern "Ubuntu"
        
        if (-not $ubuntuInstalled) {
            Write-Message "Đang cài đặt Ubuntu (phiên bản mới nhất)..." "Info"
            wsl --install -d Ubuntu
            Write-Message "Ubuntu đã được cài đặt! Vui lòng thiết lập username và password khi được yêu cầu." "Success"
        } else {
            Write-Message "Ubuntu đã được cài đặt!" "Success"
        }
    } elseif ($Distro -eq "NixOS") {
        Write-Message "Kiểm tra NixOS trên WSL..." "Info"
        
        $nixosInstalled = wsl --list | Select-String -Pattern "NixOS"
        
        if (-not $nixosInstalled) {
            Write-Message "Đang cài đặt NixOS 24.11 trên WSL..." "Info"
            
            # Tạo thư mục tạm thời
            $tempDir = "$env:TEMP\nixos-wsl"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            
            # Tải NixOS-WSL
            $nixosUrl = "https://github.com/nix-community/NixOS-WSL/releases/download/24.11/nixos-wsl.tar.gz"
            $nixosTarball = "$tempDir\nixos-wsl.tar.gz"
            
            Write-Message "Đang tải NixOS-WSL..." "Info"
            Invoke-WebRequest -Uri $nixosUrl -OutFile $nixosTarball
            
            # Cài đặt NixOS-WSL
            Write-Message "Đang cài đặt NixOS-WSL..." "Info"
            wsl --import NixOS $env:LOCALAPPDATA\NixOS $nixosTarball
            
            Write-Message "NixOS đã được cài đặt!" "Success"
        } else {
            Write-Message "NixOS đã được cài đặt!" "Success"
        }
    }
}

# Thiết lập cấu hình người dùng
# Update the Setup-UserProfile function
function Setup-UserProfile {
    param (
        [string]$Distro
    )
    
    Write-Message "Thiết lập cấu hình người dùng cho $Distro..." "Info"
    
    # Lấy thông tin từ người dùng
    $hostname = Read-Host "Nhập hostname"
    $username = Read-Host "Nhập username"
    $fullname = Read-Host "Nhập họ tên đầy đủ"
    $email = Read-Host "Nhập email"
    
    if ($Distro -eq "Ubuntu") {
        # Tạo script bash để thiết lập cấu hình trên Ubuntu
        $setupScript = @"
#!/bin/bash
# Thiết lập cấu hình người dùng trên Ubuntu

# Cập nhật hostname
sudo hostnamectl set-hostname $hostname

# Tạo thư mục cấu hình
mkdir -p ~/.config/nixpkgs/home/profiles/$username

# Copy template profile và thay thế các placeholder
cp -r ~/.config/nixpkgs/home/profiles/template/. ~/.config/nixpkgs/home/profiles/$username/

# Replace placeholders in the default.nix file
sed -i "s|{{USERNAME}}|$username|g" ~/.config/nixpkgs/home/profiles/$username/default.nix
sed -i "s|{{HOMEDIR}}|/home/$username|g" ~/.config/nixpkgs/home/profiles/$username/default.nix
sed -i "s|{{FULLNAME}}|$fullname|g" ~/.config/nixpkgs/home/profiles/$username/default.nix
sed -i "s|{{EMAIL}}|$email|g" ~/.config/nixpkgs/home/profiles/$username/default.nix

echo "Đã thiết lập cấu hình người dùng cho $username trên $hostname!"
"@
        
        # Similar updates for NixOS section...
    }
}

# Lưu script vào file tạm thời
        $tempScript = "$env:TEMP\setup-ubuntu-profile.sh"
        $setupScript | Out-File -FilePath $tempScript -Encoding ASCII
        
        # Chạy script trên Ubuntu
        wsl -d Ubuntu bash -c "cat > ~/setup-profile.sh && chmod +x ~/setup-profile.sh && ~/setup-profile.sh" < $tempScript
        
    } elseif ($Distro -eq "NixOS") {
        # Tạo script bash để thiết lập cấu hình trên NixOS
        $setupScript = @"
#!/bin/bash
# Thiết lập cấu hình người dùng trên NixOS

# Cập nhật hostname
sudo hostnamectl set-hostname $hostname

# Tạo thư mục cấu hình
mkdir -p ~/.config/nixpkgs/home/profiles/$username

# Tạo file cấu hình default.nix cho profile
cat > ~/.config/nixpkgs/home/profiles/$username/default.nix << EOF
{ config, pkgs, ... }:

{
  # Cấu hình cá nhân cho $username
  home.username = "$username";
  home.homeDirectory = "/home/$username";
  
  # Thêm stateVersion để tránh lỗi
  home.stateVersion = "24.11";
  
  # Các gói cá nhân
  home.packages = with pkgs; [
    # Thêm các gói cá nhân ở đây
    git
    vim
    vscode
  ];
  
  # Cấu hình cá nhân khác
  programs = {
    # Cấu hình các chương trình ở đây
    zsh.enable = true;
  };
}
EOF

echo "Đã thiết lập cấu hình người dùng cho $username trên $hostname!"
"@
        
        # Lưu script vào file tạm thời
        $tempScript = "$env:TEMP\setup-nixos-profile.sh"
        $setupScript | Out-File -FilePath $tempScript -Encoding ASCII
        
        # Chạy script trên NixOS
        wsl -d NixOS bash -c "cat > ~/setup-profile.sh && chmod +x ~/setup-profile.sh && ~/setup-profile.sh" < $tempScript
    }
    
    Write-Message "Đã thiết lập cấu hình người dùng cho $username trên $hostname!" "Success"
}

# Áp dụng cấu hình
function Apply-Configuration {
    param (
        [string]$Distro,
        [string]$Hostname,
        [string]$Username
    )
    
    Write-Message "Áp dụng cấu hình trên $Distro..." "Info"
    
    # Tạo script bash để áp dụng cấu hình
    $applyScript = @"
#!/bin/bash
# Áp dụng cấu hình

# Kiểm tra xem flake.nix đã tồn tại chưa
if [ -f "\$HOME/.config/nixpkgs/flake.nix" ]; then
    echo "Đang áp dụng cấu hình..."
    if [ "$Distro" == "NixOS" ]; then
        # Rebuild hệ thống NixOS
        sudo nixos-rebuild switch --flake "\$HOME/.config/nixpkgs#$Hostname"
    else
        # Áp dụng home-manager
        nix run home-manager/master -- switch --flake "\$HOME/.config/nixpkgs#$Username@$Hostname"
    fi
    echo "Đã áp dụng cấu hình thành công!"
else
    echo "Không tìm thấy file flake.nix. Vui lòng kiểm tra lại cấu trúc thư mục."
    exit 1
fi
"@
    
    # Lưu script vào file tạm thời
    $tempScript = "$env:TEMP\apply-configuration.sh"
    $applyScript | Out-File -FilePath $tempScript -Encoding ASCII
    
    # Chạy script trên distro
    wsl -d $Distro bash -c "cat > ~/apply-configuration.sh && chmod +x ~/apply-configuration.sh && ~/apply-configuration.sh" < $tempScript
    
    Write-Message "Cấu hình đã được áp dụng trên $Distro!" "Success"
}

# Hàm chính
function Main {
    Write-Message "Bắt đầu thiết lập môi trường Windows/WSL..." "Info"
    
    # Kiểm tra quyền admin
    if (-not (Test-Administrator)) {
        Write-Message "Script này cần được chạy với quyền Administrator. Vui lòng chạy lại với quyền Administrator." "Error"
        return
    }
    
    # Kiểm tra và bật WSL
    if (-not (Enable-WSL)) {
        return
    }
    
    # Cài đặt WSL2 Linux kernel update
    Install-WSL2Kernel
    
    # Hỏi người dùng muốn cài đặt distro nào
    Write-Message "Bạn muốn cài đặt distro nào trên WSL?" "Info"
    Write-Host "1. Ubuntu (phiên bản mới nhất)"
    Write-Host "2. NixOS (phiên bản 24.11)"
    $distroChoice = Read-Host "Nhập lựa chọn của bạn (1 hoặc 2)"
    
    $distro = ""
    if ($distroChoice -eq "1") {
        $distro = "Ubuntu"
        Install-LinuxDistro -Distro $distro
    } elseif ($distroChoice -eq "2") {
        $distro = "NixOS"
        Install-LinuxDistro -Distro $distro
    } else {
        Write-Message "Lựa chọn không hợp lệ!" "Error"
        return
    }
    
    # Clone repository dotfiles
    Clone-Dotfiles -Distro $distro
    
    # Thiết lập cấu hình người dùng
    Setup-UserProfile -Distro $distro
    
    # Lấy thông tin hostname và username
    $hostname = Read-Host "Xác nhận lại hostname"
    $username = Read-Host "Xác nhận lại username"
    
    # Áp dụng cấu hình
    Apply-Configuration -Distro $distro -Hostname $hostname -Username $username
    
    Write-Message "Thiết lập hoàn tất! Hệ thống đã được cấu hình theo dotfiles." "Success"
}

# Chạy hàm chính
Main
