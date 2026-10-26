# webpz

面向开发者和 AI agent 的图片压缩 CLI：目标体积、SSIM 质量下限、批量转换和 JSON 输出。

这是 webpz 的公开分发仓库，包含安装脚本、使用说明和 [Release 下载](https://github.com/HelloVass/webpz/releases)。源码与构建流程在私有仓库维护。

## 安装

先安装 libwebp 工具（`cwebp`、`dwebp`）：

```bash
# macOS
brew install webp

# Debian / Ubuntu
sudo apt install webp

# Fedora
sudo dnf install libwebp-tools
```

下载并运行安装脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/HelloVass/webpz/main/install.sh -o /tmp/webpz-install.sh
bash /tmp/webpz-install.sh
```

安装器自动选择 macOS / Linux 的 arm64 / x64 二进制，验证 SHA-256 后安装到 `~/.local/bin/webpz`。CLI 无需 Java、Node.js 或 Python。

```bash
export PATH="$HOME/.local/bin:$PATH"
webpz --version
webpz doctor
webpz init
```

将上面的 PATH 配置加入你的 shell 配置文件（例如 `~/.zshrc`）。`webpz init` 会探测已安装的 agent 并安装内置 skill。

指定版本或安装位置：

```bash
WEBPZ_VERSION=0.1.0 WEBPZ_INSTALL_DIR="$HOME/.local/bin" bash /tmp/webpz-install.sh
```

升级时重新运行安装脚本，再执行 `webpz skill update`。

## 使用

```bash
# 查看尺寸、透明通道和推荐压缩参数
webpz inspect ./hero.png --json

# 压到 500 KiB 以内
webpz compress ./hero.png --max-kb 500

# 批量压缩，输出到另一个目录
webpz compress ./assets --max-width 2400 --out-dir ./compressed --json

# UI 截图，设置质量下限
webpz compress ./screen.png --preset ui --min-ssim 0.97

# 无损转换
webpz compress ./logo.png --lossless

# 预览计划
webpz compress ./assets --max-kb 300 --dry-run --json
```

默认保留原图、不覆盖已有输出。无法同时满足体积和质量约束时返回失败，JSON 中包含错误原因。

| 命令 | 用途 |
| --- | --- |
| `compress` | 压缩、缩放、批处理与质量检查 |
| `inspect` | 查看图片信息与推荐参数 |
| `doctor` | 检查 libwebp 与 skill 安装状态 |
| `init` | 探测 agent 并安装 skill |
| `skill install/update/remove/list` | 管理内置 skill |

完整参数见 `webpz --help`、`webpz compress --help`。

## 平台与依赖

| 平台 | Release 文件 |
| --- | --- |
| macOS Apple Silicon | `webpz-darwin-arm64.tar.gz` |
| macOS Intel | `webpz-darwin-x64.tar.gz` |
| Linux x64 | `webpz-linux-x64.tar.gz` |
| Linux arm64 | `webpz-linux-arm64.tar.gz` |

Linux 使用 glibc，构建环境为 Ubuntu 22.04；Alpine/musl 不在支持范围内。压缩包包含 CLI 和使用说明，libwebp 由系统包管理器安装，也可通过 `WEBPZ_BIN_DIR` 指定工具目录。HEIC/AVIF 输入还需要系统转换工具：macOS 使用 `sips`，Linux 使用 `heif-convert` 或 ImageMagick。

每个压缩包附带 `.sha256` 校验文件。手动下载后可验证：

```bash
shasum -a 256 -c webpz-darwin-arm64.tar.gz.sha256
tar -xzf webpz-darwin-arm64.tar.gz
./webpz --version
```

问题反馈请使用本仓库的 [Issues](https://github.com/HelloVass/webpz/issues)，附上 `webpz --version`、`webpz doctor --json` 和复现命令。
