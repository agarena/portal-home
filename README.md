# 门户首页（agarena.xyz）

「不吃鲸B」个人站首页：工具展示（token定价对比 / 提示词聚合网站）、网页作品精选、91 套模板画廊导航、跑马灯动态、访客统计埋点。

- 线上地址：<https://agarena.xyz>
- 内容数据：运行时从 `api.agarena.xyz` 拉取 `/api/tools`、`/api/feed`、`/api/site`（后端见 agarena/analytics-worker 仓库），拉取失败降级为内置示例（改内置示例需同步 seed.sql）

## 目录

```
index.html   单文件页面（内联 CSS/JS，无构建）
fonts/       自托管字体
assets/      工具卡配图等静态资源
```

## 发布

本仓库与「网站作品」仓库（works/ + gallery/）**联合发布**到同一个 Cloudflare Pages 项目 `shufy-site`（域名 agarena.xyz），并同步更新 GitHub Pages 镜像（agarena/demo-site 仓库，自动构建勿手改）：

```bash
# 在本仓库根目录（需 Cloudflare 授权：export CLOUDFLARE_API_TOKEN=… 或 wrangler login）
bash publish.sh
```

`publish.sh` 做三件事：拼装两仓内容到 `_pages-dist` → `wrangler pages deploy` 发布 agarena.xyz → 更新 demo-site 镜像仓并 push。

- 作品仓默认路径 `../网站作品`，可用 `WORKS_DIR` 环境变量覆盖。
- 首次使用需先 `git clone git@github.com:agarena/demo-site.git ../.mirror/demo-site` 作为镜像 checkout。
