#!/bin/bash

# setup-darwin.sh - Script tự động thiết lập và cấu hình cho macOS
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

# Kiểm tra xem Homebrew đã được cài đặt chưa
check_homebrew() {
  print_message "Kiểm tra Homebrew..."
  if ! command -v brew &> /dev/null; then
    print_message "Homebrew chưa được cài đặt. Đang cài đặt Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew đã được cài đặt thành công!"
  else
    print_success "Homebrew đã được cài đặt!"
  fi
}

# Kiểm tra xem Nix đã được cài đặt chưa
check_nix() {
  print_message "Kiểm tra Nix..."
  if ! command -v nix &> /dev/null; then
    print_message "Nix chưa được cài đặt. Đang cài đặt Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    print_success "Nix đã được cài đặt thành công!"
  else
    print_success "Nix đã được cài đặt!"
  fi
}

# Kiểm tra xem nix-darwin đã được cài đặt chưa
check_nix_darwin() {
  print_message "Kiểm tra nix-darwin..."
  # We don't need to manually install nix-darwin since it's managed through flakes
  # Just check if the flake.nix exists and contains darwin configuration
  if [ -f "$HOME/.config/nixpkgs/flake.nix" ] && grep -q "darwin" "$HOME/.config/nixpkgs/flake.nix"; then
    print_success "nix-darwin sẽ được quản lý thông qua flake!"
  else
    print_warning "Không tìm thấy cấu hình darwin trong flake.nix. Hãy đảm bảo flake.nix đã được thiết lập đúng."
  fi
}

# Clone repository dotfiles
clone_dotfiles() {
  print_message "Kiểm tra repository dotfiles..."
  
  DOTFILES_DIR="$HOME/aurora-dotfiles"
  
  if [ -d "$DOTFILES_DIR" ]; then
    # When updating the dotfiles repository
    echo "==> Repository dotfiles đã tồn tại. Đang cập nhật..."
    
    # Check if there are unstaged changes
    if [ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" ]; then
      print_warning "Phát hiện thay đổi chưa commit trong repository."
      read -p "Bạn muốn (1) stash các thay đổi, (2) bỏ qua việc cập nhật, hay (3) thoát? [1/2/3]: " choice
      
      case "$choice" in
        1)
          print_message "Đang stash các thay đổi..."
          git -C "$DOTFILES_DIR" stash
          print_message "Đang cập nhật repository..."
          git -C "$DOTFILES_DIR" pull --rebase
          ;;
        2)
          print_warning "Bỏ qua việc cập nhật repository."
          ;;
        3)
          print_error "Thoát theo yêu cầu của người dùng."
          exit 1
          ;;
        *)
          print_warning "Lựa chọn không hợp lệ. Bỏ qua việc cập nhật repository."
          ;;
      esac
    else
      # No unstaged changes, proceed with pull
      git -C "$DOTFILES_DIR" pull --rebase
    fi
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

# Thiết lập cấu hình người dùng
# Update the setup_user_profile function
setup_user_profile() {
  print_message "Thiết lập cấu hình người dùng..."
  
  # Lấy thông tin từ người dùng
  read -p "Nhập hostname: " hostname
  read -p "Nhập username: " username
  read -p "Nhập họ tên đầy đủ: " fullname
  read -p "Nhập email: " email
  
  # Tạo thư mục profile nếu chưa tồn tại
  mkdir -p "$DOTFILES_DIR/home/profiles/$username"
  
  # Create default.nix file directly instead of using sed
  cat > "$DOTFILES_DIR/home/profiles/$username/default.nix" << EOF
{ config, pkgs, ... }:

{
  # Cấu hình cá nhân cho $username
  home.username = "$username";
  home.homeDirectory = "/Users/$username";
  
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
    git = {
      enable = true;
      userName = "$fullname";
      userEmail = "$email";
    };
    
    # Cấu hình các chương trình ở đây
    zsh.enable = true;
  };
}
EOF
  
  # Cập nhật hostname
  sudo scutil --set HostName "$hostname"
  
  print_success "Đã thiết lập cấu hình người dùng cho $username trên $hostname!"
}

# Áp dụng cấu hình
apply_configuration() {
  print_message "Áp dụng cấu hình..."
  
  # Kiểm tra xem flake.nix đã tồn tại chưa
  if [ -f "$HOME/.config/nixpkgs/flake.nix" ]; then
    # Update flake inputs first
    print_message "Cập nhật flake inputs..."
    cd "$HOME/.config/nixpkgs" && nix flake update
    
    # Rebuild hệ thống
    print_message "Rebuild hệ thống..."
    darwin-rebuild switch --flake "$HOME/.config/nixpkgs#$hostname"
    print_success "Đã áp dụng cấu hình thành công!"
  else
    print_error "Không tìm thấy file flake.nix. Vui lòng kiểm tra lại cấu trúc thư mục."
    exit 1
  fi
}

# Hàm chính
main() {
  print_message "Bắt đầu thiết lập môi trường macOS..."
  
  # Kiểm tra các công cụ cần thiết
  check_homebrew
  check_nix
  check_nix_darwin
  
  # Clone và cài đặt dotfiles
  clone_dotfiles
  
  # Thiết lập cấu hình người dùng
  setup_user_profile
  
  # Áp dụng cấu hình
  apply_configuration
  
  print_success "Thiết lập hoàn tất! Hệ thống đã được cấu hình theo dotfiles."
}

# Chạy hàm chính
main
