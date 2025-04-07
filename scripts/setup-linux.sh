#!/bin/bash

# setup-linux.sh - Script tự động thiết lập và cấu hình cho Linux (NixOS, Ubuntu)
# Phần của Aurora Freedom Project Dotfiles

set -e

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hàm hiển thị thông báo
print_message() {
  echo -e "${BLUE}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}==>${NC} $1"
}

print_error() {
  echo -e "${RED}==>${NC} $1"
}

# Kiểm tra hệ điều hành
check_os() {
  print_message "Kiểm tra hệ điều hành..."
  
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    
    if [[ "$OS" == *"NixOS"* ]]; then
      print_success "Phát hiện NixOS!"
      OS_TYPE="nixos"
    elif [[ "$OS" == *"Ubuntu"* ]]; then
      print_success "Phát hiện Ubuntu!"
      OS_TYPE="ubuntu"
    else
      print_warning "Hệ điều hành không được hỗ trợ đầy đủ: $OS. Tiếp tục với cấu hình cơ bản."
      OS_TYPE="other"
    fi
  else
    print_error "Không thể xác định hệ điều hành. Vui lòng chạy trên NixOS hoặc Ubuntu."
    exit 1
  fi
}

# Kiểm tra và cài đặt Nix trên Ubuntu
setup_nix_ubuntu() {
  if [ "$OS_TYPE" == "ubuntu" ]; then
    print_message "Kiểm tra Nix trên Ubuntu..."
    
    if ! command -v nix &> /dev/null; then
      print_message "Nix chưa được cài đặt. Đang cài đặt Nix..."
      sh <(curl -L https://nixos.org/nix/install) --daemon
      
      # Thêm channels
      . /etc/profile
      nix-channel --add https://nixos.org/channels/nixpkgs-unstable
      nix-channel --update
      
      print_success "Nix đã được cài đặt thành công!"
    else
      print_success "Nix đã được cài đặt!"
    fi
  fi
}

# Clone repository dotfiles
clone_dotfiles() {
  print_message "Kiểm tra repository dotfiles..."
  
  DOTFILES_DIR="$HOME/aurora-dotfiles"
  
  if [ -d "$DOTFILES_DIR" ]; then
    print_message "Repository dotfiles đã tồn tại. Đang cập nhật..."
    cd "$DOTFILES_DIR"
    git pull
  else
    print_message "Đang clone repository dotfiles..."
    git clone https://github.com/aurora-freedom-project/dotfiles.git "$DOTFILES_DIR"
  fi
  
  print_success "Repository dotfiles đã sẵn sàng!"
  
  # Tạo thư mục .config/nixpkgs nếu chưa tồn tại
  mkdir -p "$HOME/.config/nixpkgs"
  
  # Sao chép các file cấu hình từ repository vào .config/nixpkgs
  print_message "Đang sao chép các file cấu hình..."
  cp -r "$DOTFILES_DIR"/* "$HOME/.config/nixpkgs/"
  
  print_success "Đã sao chép các file cấu hình!"
}

# Thiết lập cấu hình NixOS
setup_nixos() {
  if [ "$OS_TYPE" == "nixos" ]; then
    print_message "Thiết lập cấu hình NixOS..."
    
    # Yêu cầu file hardware-configuration.nix
    print_message "NixOS yêu cầu file hardware-configuration.nix."
    read -p "Đường dẫn đến file hardware-configuration.nix hiện tại: " hw_config_path
    
    if [ -f "$hw_config_path" ]; then
      # Tạo thư mục nếu chưa tồn tại
      mkdir -p "$HOME/.config/nixos"
      
      # Sao chép file hardware-configuration.nix
      cp "$hw_config_path" "$HOME/.config/nixos/hardware-configuration.nix"
      print_success "Đã sao chép file hardware-configuration.nix!"
    else
      print_error "Không tìm thấy file hardware-configuration.nix. Vui lòng kiểm tra lại đường dẫn."
      exit 1
    fi
  fi
}

# Thiết lập cấu hình người dùng
setup_user_profile() {
  print_message "Thiết lập cấu hình người dùng..."
  
  # Lấy thông tin từ người dùng
  read -p "Nhập hostname: " hostname
  read -p "Nhập username: " username
  
  # Tạo thư mục profile nếu chưa tồn tại
  mkdir -p "$HOME/.config/nixpkgs/home/profiles/$username"
  
  # Tạo file cấu hình default.nix cho profile
  cat > "$HOME/.config/nixpkgs/home/profiles/$username/default.nix" << EOF
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
  
  # Cập nhật hostname nếu có quyền sudo
  if command -v sudo &> /dev/null; then
    sudo hostnamectl set-hostname "$hostname"
  fi
  
  print_success "Đã thiết lập cấu hình người dùng cho $username trên $hostname!"
}

# Áp dụng cấu hình
apply_configuration() {
  print_message "Áp dụng cấu hình..."
  
  # Kiểm tra xem flake.nix đã tồn tại chưa
  if [ -f "$HOME/.config/nixpkgs/flake.nix" ]; then
    if [ "$OS_TYPE" == "nixos" ]; then
      # Rebuild hệ thống NixOS
      sudo nixos-rebuild switch --flake "$HOME/.config/nixpkgs#$hostname"
    else
      # Áp dụng home-manager
      nix run home-manager/master -- switch --flake "$HOME/.config/nixpkgs#$username@$hostname"
    fi
    print_success "Đã áp dụng cấu hình thành công!"
  else
    print_error "Không tìm thấy file flake.nix. Vui lòng kiểm tra lại cấu trúc thư mục."
    exit 1
  fi
}

# Hàm chính
main() {
  print_message "Bắt đầu thiết lập môi trường Linux..."
  
  # Kiểm tra hệ điều hành
  check_os
  
  # Thiết lập Nix trên Ubuntu nếu cần
  setup_nix_ubuntu
  
  # Clone và cài đặt dotfiles
  clone_dotfiles
  
  # Thiết lập cấu hình NixOS nếu đang chạy trên NixOS
  setup_nixos
  
  # Thiết lập cấu hình người dùng
  setup_user_profile
  
  # Áp dụng cấu hình
  apply_configuration
  
  print_success "Thiết lập hoàn tất! Hệ thống đã được cấu hình theo dotfiles."
}

# Chạy hàm chính
main
