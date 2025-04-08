# Aurora Freedom Project Dotfiles

## For New Team Members

1. Fork this repository
2. Copy the template profile:
   ```bash
   cp -r home/profiles/template home/profiles/yourusername
   ```

Repository này chứa các dotfiles được quản lý bằng Nix và Nix Flakes, hỗ trợ nhiều nền tảng khác nhau bao gồm NixOS, macOS, Ubuntu và Windows/WSL2.

## Tổng quan

Dự án này được thiết kế để cung cấp một template chung cho toàn bộ team, đồng thời cho phép các thành viên tùy chỉnh cấu hình riêng của họ. Cấu trúc dự án được tổ chức để hỗ trợ:

- **Đa nền tảng**: Hỗ trợ NixOS, macOS (thông qua nix-darwin), Ubuntu và Windows (thông qua WSL2)
- **Tự động hóa**: Script tự động thiết lập cho mỗi nền tảng
- **Mô-đun hóa**: Các cấu hình được chia thành các module riêng biệt
- **Cá nhân hóa**: Hỗ trợ profile cá nhân cho từng thành viên

## Cấu trúc thư mục

```
dotfiles/
├── flake.nix                  # File flake chính
├── README.md                  # Tài liệu hướng dẫn
├── scripts/                   # Các script tự động hóa
│   ├── setup-darwin.sh        # Script thiết lập cho macOS
│   ├── setup-linux.sh         # Script thiết lập cho Linux (NixOS, Ubuntu)
│   └── Setup-WSL.ps1          # Script PowerShell thiết lập cho Windows/WSL
├── hosts/                     # Cấu hình cho từng máy
│   ├── nixos/                 # Cấu hình cho NixOS
│   │   ├── common.nix         # Cấu hình chung cho NixOS
│   │   ├── legion/            # Cấu hình Lenovo Legion
│   │   │   ├── default.nix
│   │   │   └── hardware-configuration.nix
│   │   └── wsl/               # Cấu hình cho WSL
│   │       └── default.nix
│   ├── darwin/                # Cấu hình cho macOS
│   │   ├── common.nix         # Cấu hình chung cho macOS
│   │   └── macbook/
│   │       └── default.nix
│   └── ubuntu/                # Cấu hình cho Ubuntu
│       └── default.nix
├── modules/                   # Các module chức năng
│   ├── nixos/                 # Module chỉ dùng cho NixOS
│   │   ├── desktop.nix
│   │   ├── nvidia.nix
│   │   └── virtualization.nix
│   ├── darwin/                # Module chỉ dùng cho macOS
│   │   └── default.nix
│   └── shared/                # Module dùng chung nhiều OS
│       ├── packages/          # Danh sách các gói phần mềm
│       │   ├── common.nix     # Gói chung mọi OS
│       │   ├── nixos.nix      # Gói dành cho NixOS
│       │   ├── darwin.nix     # Gói dành cho macOS
│       │   └── ubuntu.nix     # Gói dành cho Ubuntu
│       └── programs/          # Cấu hình cho các ứng dụng
│           ├── git.nix        # Cấu hình Git
│           ├── shell.nix      # Cấu hình Shell
│           └── terminals.nix  # Cấu hình Terminal
└── home/                      # Cấu hình Home Manager
    ├── linux.nix              # Home Manager cho Linux (NixOS & Ubuntu)
    ├── darwin.nix             # Home Manager cho macOS
    └── profiles/              # Cấu hình người dùng cụ thể
        ├── rnd/               # Cho user rnd (Linux)
        │   └── default.nix
        └── mike/              # Cho user mike (macOS)
            └── default.nix
```

## Hướng dẫn cài đặt

### macOS

1. Mở Terminal
2. Tải script thiết lập:
   ```bash
   curl -o setup-darwin.sh https://raw.githubusercontent.com/aurora-freedom-project/dotfiles/main/scripts/setup-darwin.sh
   chmod +x setup-darwin.sh
   ```
3. Chạy script:
   ```bash
   ./setup-darwin.sh
   ```
4. Làm theo các hướng dẫn trên màn hình để hoàn tất cài đặt

Script sẽ tự động:
- Cài đặt Homebrew nếu chưa có
- Cài đặt Nix nếu chưa có
- Cài đặt nix-darwin
- Thiết lập cấu hình người dùng
- Áp dụng cấu hình

### Linux (NixOS, Ubuntu)

1. Mở Terminal
2. Tải script thiết lập:
   ```bash
   curl -o setup-linux.sh https://raw.githubusercontent.com/aurora-freedom-project/dotfiles/main/scripts/setup-linux.sh
   chmod +x setup-linux.sh
   ```
3. Chạy script:
   ```bash
   ./setup-linux.sh
   ```
4. Làm theo các hướng dẫn trên màn hình để hoàn tất cài đặt

Script sẽ tự động:
- Phát hiện hệ điều hành (NixOS hoặc Ubuntu)
- Cài đặt Nix trên Ubuntu nếu cần
- Yêu cầu file hardware-configuration.nix nếu đang chạy trên NixOS
- Thiết lập cấu hình người dùng
- Áp dụng cấu hình

### Windows (WSL2)

1. Mở PowerShell với quyền Administrator
2. Tải script thiết lập:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aurora-freedom-project/dotfiles/main/scripts/Setup-WSL.ps1" -OutFile "Setup-WSL.ps1"
   ```
3. Chạy script:
   ```powershell
   .\Setup-WSL.ps1
   ```
4. Làm theo các hướng dẫn trên màn hình để hoàn tất cài đặt

Script sẽ tự động:
- Bật tính năng WSL nếu chưa bật
- Cài đặt WSL2 Linux kernel update
- Cài đặt Ubuntu (phiên bản mới nhất) hoặc NixOS (phiên bản 24.11) theo lựa chọn
- Thiết lập cấu hình người dùng

## Tùy chỉnh cấu hình

### Thêm gói phần mềm

Để thêm gói phần mềm chung cho tất cả các nền tảng, chỉnh sửa file `modules/shared/packages/common.nix`.

Để thêm gói phần mềm cho một nền tảng cụ thể:
- NixOS: `modules/shared/packages/nixos.nix`
- macOS: `modules/shared/packages/darwin.nix`
- Ubuntu: `modules/shared/packages/ubuntu.nix`

### Tùy chỉnh cấu hình người dùng

Mỗi người dùng có thể tùy chỉnh cấu hình riêng của họ trong thư mục `home/profiles/<username>/default.nix`.

### Thêm máy mới

Để thêm cấu hình cho một máy mới:

1. Tạo thư mục mới trong `hosts/<os>/` (ví dụ: `hosts/nixos/newmachine/`)
2. Tạo file `default.nix` trong thư mục đó
3. Nếu là NixOS, thêm file `hardware-configuration.nix`
4. Cập nhật `flake.nix` để thêm cấu hình mới

## Cập nhật cấu hình

### NixOS

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### macOS

```bash
darwin-rebuild switch --flake .#<hostname>
```

### Home Manager (Ubuntu)

```bash
home-manager switch --flake .#<username>@<hostname>
```

## Đóng góp

Project này đang là base core, cần test và phát triển thêm. Anh em dùng học Nix rồi contribute lại cho project nhé :)
