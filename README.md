# webpz

面向开发者和 AI agent 的图片压缩 CLI：目标体积、SSIM 质量下限、批量转换和 JSON 输出。

这是 webpz 的公开分发仓库，包含安装脚本、使用说明和 [Release 下载](https://github.com/HelloVass/webpz/releases)。源码与构建流程在私有仓库维护。

## 安装

从 v0.2.0 起，发布版将 libwebp、PNG/JPEG 解码器静态链接进 CLI。无需 Homebrew、外部 `cwebp`、Java、Node.js、Python 或开发 SDK。

下载并运行安装脚本（需要系统自带的 Bash、curl、tar 和 SHA-256 工具）：

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
WEBPZ_VERSION=0.2.0 WEBPZ_INSTALL_DIR="$HOME/.local/bin" bash /tmp/webpz-install.sh
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
| `doctor` | 检查内嵌编码器、支持格式与 skill 安装状态 |
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

macOS 最低版本为 12.0。Linux 使用 glibc，验证环境为 Ubuntu 22.04；Alpine/musl 不在支持范围内。压缩包包含一个独立 CLI、使用说明和第三方许可证；运行时只依赖操作系统基础库，原生版不读取 `WEBPZ_BIN_DIR`，也不查找外部编码工具。

PNG/JPEG/WebP 在四个平台均由内嵌库处理。macOS 的 TIFF/HEIC/AVIF 使用系统 ImageIO，支持情况取决于系统解码能力；Linux 版不支持这三种输入，请先导出 PNG/JPEG。`--lossless` 与 SSIM 针对解码后的像素，不保证不同解码器之间逐像素一致。ICC/EXIF/XMP 保留适用于 PNG/JPEG/WebP 输入。

每个压缩包附带 `.sha256` 校验文件。手动下载后可验证：

```bash
shasum -a 256 -c webpz-darwin-arm64.tar.gz.sha256
tar -xzf webpz-darwin-arm64.tar.gz
./webpz --version
```

问题反馈请使用本仓库的 [Issues](https://github.com/HelloVass/webpz/issues)，附上 `webpz --version`、`webpz doctor --json` 和复现命令。

## 第三方组件

libwebp、zlib、libpng、libjpeg-turbo 均从固定版本源码构建。许可证与源码提交列在压缩包的 `licenses/` 中；安装器将说明保存到 `~/.local/share/webpz`（可用 `WEBPZ_DATA_DIR` 指定）。这些说明文件不是运行依赖。

This software is based in part on the work of the Independent JPEG Group.
