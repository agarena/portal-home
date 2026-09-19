#!/bin/bash
# 联合发布：门户首页(本仓库) + 网站作品(works/gallery) → agarena.xyz + GitHub Pages 镜像
# 用法：在门户首页仓库根目录执行 bash publish.sh
#   环境变量：WORKS_DIR 作品仓路径(默认 ../网站作品)
#            DIST 拼装输出目录(默认 ../_pages-dist)
#            MIRROR_DIR 镜像仓 checkout(默认 ../.mirror/demo-site，存在才同步)
#            SKIP_MIRROR=1 跳过镜像更新
# Cloudflare 授权：先 export CLOUDFLARE_API_TOKEN=… 或 wrangler login
set -euo pipefail

PORTAL_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKS_DIR="${WORKS_DIR:-$PORTAL_DIR/../网站作品}"
DIST="${DIST:-$PORTAL_DIR/../_pages-dist}"
MIRROR_DIR="${MIRROR_DIR:-$PORTAL_DIR/../.mirror/demo-site}"

for d in "$PORTAL_DIR/index.html" "$PORTAL_DIR/fonts" "$PORTAL_DIR/assets" "$WORKS_DIR/works" "$WORKS_DIR/gallery"; do
  [ -e "$d" ] || { echo "缺少 $d"; exit 1; }
done

echo "==> 1/3 拼装 _pages-dist"
rm -rf "$DIST"
mkdir -p "$DIST"
cp -r "$PORTAL_DIR/index.html" "$PORTAL_DIR/fonts" "$PORTAL_DIR/assets" "$DIST/"
cp -r "$WORKS_DIR/works" "$WORKS_DIR/gallery" "$DIST/"

echo "==> 2/3 发布 Cloudflare Pages (shufy-site → agarena.xyz)"
# 注意：不从 DIST 目录内执行 wrangler（避免写入 .wrangler 缓存污染产物）
npx wrangler pages deploy "$DIST" --project-name shufy-site --branch main

if [ "${SKIP_MIRROR:-0}" != "1" ] && [ -d "$MIRROR_DIR/.git" ]; then
  echo "==> 3/3 同步 GitHub Pages 镜像 (agarena/demo-site)"
  cd "$MIRROR_DIR"
  git checkout -q main
  git pull -q
  # 清空旧内容（保留 .git 与镜像说明文件）后整树替换，等效 rsync --delete
  find . -mindepth 1 -maxdepth 1 ! -name '.git' ! -name 'README.md' -exec rm -rf {} +
  cp -r "$DIST/." .
  git add -A
  if git diff --cached --quiet; then
    echo "镜像无变化，跳过"
  else
    git commit -qm "mirror: auto-built from 门户首页+网站作品 $(date '+%Y-%m-%d %H:%M')"
    git push -q origin main
    echo "镜像已推送"
  fi
else
  echo "==> 3/3 跳过镜像更新（未设置或 SKIP_MIRROR=1）"
fi
echo "✅ 发布完成：https://agarena.xyz"
