---
title: 使用 Hexo 在 Github 搭建个人网站
date: 2021-03-21 16:39:24
top: true
cover: false
categories: 
- 网站建设
tags:
- Hexo
- Github
---

## 简介

使用 [Hexo](https://hexo.io/docs/) 可以在 Github Page 搭建个人博客，但从零开始搭建过程较为繁琐，故做了此模板以简化创建流程。

Hexo 至少需要两个相关的 Github 仓库，如：

- [`hexo-template`](https://github.com/lyy289065406/hexo-template)： 用于【管理】和【数据存储】，可运行测试环境
- [`articles`](https://github.com/lyy289065406/articles)： 用于生产环境【展示】内容

> Fork [`hexo-template`](https://github.com/lyy289065406/hexo-template) 并改名，即可作为自定义博客的管理后台；[`articles`](https://github.com/lyy289065406/articles) 则自建一个任意命名的空仓库即可；下文会继续沿用这两个名称以便于说明


各个环境的站点 URL 如下：

- 本地测试环境： [http://127.0.0.1:4000](http://127.0.0.1:4000)
- 线上测试环境： [https://lyy289065406.github.io/hexo-template/](https://lyy289065406.github.io/hexo-template/)
- 线上生产环境： [https://exp-blog.com](https://exp-blog.com) 或 [https://lyy289065406.github.io/articles/](https://lyy289065406.github.io/articles/)

> 域名只是举例，实际使用时按需修改即可


## 部署说明

### 准备工作

- 任意找一台 Linux/Windows/Mac 服务器（阿里云、腾讯云等）
- 安装 Docker
- 把当前仓库 checkout 到服务器： `git clone https://github.com/lyy289065406/hexo-template`
- 新建名为 articles 的空仓库（用于发布正式环境的博客内容）： `https://github.com/lyy289065406/articles`
- 设置宿主机可使用 SSH 与 Github 连接（用于把 Hexo 内容发布到正式环境），可参考 [官方教程](https://help.github.com/en/articles/connecting-to-github-with-ssh)：主要就是把配置存储在 `~/.ssh/` 下的 SSH 公钥设置到 Github （首次设置完成后须在宿主机执行 `ssh -T git@github.com` 命令信任连接）

> [`hexo-template`](https://github.com/lyy289065406/hexo-template) 和 [`articles`](https://github.com/lyy289065406/articles) 两个仓库均要开通 GitHub Pages 服务


### 初始化环境

初始化用于 Hexo 运行的 Docker 环境镜像：

`./init.sh -e "${GITHUB_EMAIL}" -u "${GITHUB_USER}" -n "${DEPLOY_REPO_NAME}" -d "${BLOG_DOMAIN}"`

其中要用到的参数如下：

- `GITHUB_EMAIL`： Github 的 Email
- `GITHUB_USER`： Github 的账号
- `DEPLOY_REPO_NAME`： 正式环境的 Github 仓库名称，用于发布博客内容（可以新建仓库，但不能是当前仓库）
- `BLOG_DOMAIN`: 博客域名，若未申请可留空（此时自动使用 Github Page 的子域名）

> 示例： `./init.sh -e "289065406@qq.com" -u "lyy289065406" -n "articles" -d "exp-blog.com"`


### 插件安装（可选） 

- 安装： `./exec.sh npm i --save ${PLUGIN_NAME}`
- 卸载： `./exec.sh npm uninstall ${PLUGIN_NAME}`
- 更新： `./exec.sh npm install --save`


### 添加文章

可以通过命令直接创建新文章： `./exec.sh hexo new ${ARTICLE_TITLE}`

该命令会在 [`hexo/source/_posts/`](hexo/source/_posts) 目录下创建 2 个文件：

- `${ARTICLE_TITLE}`： 该文章的资源目录
- `${ARTICLE_TITLE}.md`： 该文章的 markdown 文件，其默认内容只有 [Front-matter](https://hexo.io/zh-cn/docs/front-matter.html) 区域：

```
---
title: ${ARTICLE_TITLE}
date: 2020-09-06 03:15:13
tags:
---
```

也可以直接在 [`hexo/source/_posts/`](hexo/source/_posts) 目录下创建 markdown 文件和同名目录，效果是一样的。


### 构建博客内容

执行 `./build.sh` 或 `./build.sh -e test` 均可。

该命令会根据 [`hexo/source/`](hexo/source) 目录下的 markdown 文件在 [`hexo/public/`](hexo/public) 目录下生成 html 格式的站点内容。


### 启动 Hexo 服务（本地测试环境）

执行 `./run.sh` 或 `./run.sh -p ${PORT}` 均可，服务默认在 4000 端口。

> 本地测试环境 URL： [http://127.0.0.1:4000](http://127.0.0.1:4000) 


### 停止 Hexo 服务

执行 `./stop.sh` 即可。


### 发布内容（线上测试环境）

执行以下命令把本仓库的变更内容提交到 Github 即可：

- `git add --all`
- `git commit -m "deploy to test"`
- `git push`

> 线上测试环境 URL： [https://lyy289065406.github.io/hexo-template/](https://lyy289065406.github.io/hexo-template/)


### 发布内容（线上正式环境）

执行 `./build.sh -e prod` 即可。

- 若有自定义域名，直接执行： `./build.sh -e prod`
- 若无自定义域名，则需声明，此时会使用 Github 子域名： `./build.sh -e prod -d no`

> 线上正式环境 URL：
<br/>　　已绑定自定义域名： [https://exp-blog.com](https://exp-blog.com) 
<br/>　　未绑定自定义域名： [https://lyy289065406.github.io/articles/](https://lyy289065406.github.io/articles/)


## 目录说明

```
hexo-template
├── hexo ................................. 通过 hexo init 命令生成的工作目录
│   ├── node_modules ..................... 插件目录，npm install 命令会根据 package.json 安装
│   ├── themes ........................... 主题目录，从 https://hexo.io/themes/ 按喜好选择即可
│   │   └── * ............................ 每个主题一个独立目录
│   │       ├── languages ................ 该主题支持的语言环境
│   │       └── _config.yml .............. 主题配置文件
│   ├── scaffolds ........................ 模板目录
│   │   ├── draft ........................ 草稿模板
│   │   ├── post ......................... 文章模板
│   │   └── page ......................... 页面模板
│   ├── source ........................... Markdown 资源目录
│   │   ├── _data ........................ 可被 Hexo/主题/插件 引用的公共数据目录
│   │   ├── download ..................... 存储本地下载资源的目录
│   │   ├── images ....................... 可被文章引用的公共图片目录
│   │   ├── _draft ....................... Markdown 草稿目录（不会发布）
│   │   ├── _posts ....................... Markdown 文章/资源目录
│   │   ├── categories ................... 【分类】页面
│   │   ├── tags ......................... 【标签】页面
│   │   ├── friends ...................... 【友情链接】页面
│   │   ├── concat ....................... 【解锁指引】页面
│   │   └── about ........................ 【关于】页面
│   ├── public ........................... Html 站点目录（根据 source 生成）
│   ├── .deploy_git ...................... Html 发布目录（根据 public 生成）
│   ├── db.json .......................... 用于生成站点数据的缓存文件
│   ├── package.json ..................... 记录 hexo 及其插件版本
│   ├── package-lock.json ................ 记录实际安装的各个插件的具体来源和版本号
│   ├── yarn.lock ........................ 由 Yarn 自动创建，并且完全通过 Yarn 进行操作
│   └── _config.yml ...................... Hexo 配置文件
├── .gitignore ........................... git 忽略文件
├── .nojekyll ............................ 声明忽略 jekyll ，避免 Github Pages 构建失败
├── init.sh/ps1 .......................... 构建 hexo 的 docker 环境的脚本
├── build.sh/ps1 ......................... 生成 hexo 发布内容的的脚本
├── run.sh/ps1 ........................... 运行 hexo 服务（测试环境）
├── stop.sh/ps1 .......................... 停止 hexo 服务（测试环境）
├── exec.sh/ps1 .......................... 利用 docker 环境执行任意 hexo 命令的脚本
├── to_sha256.sh/ps1 ..................... 用于设置文章密码的脚本
├── index.html ........................... 可自动跳转到 hexo/public/index.html 页面 
└── README.md ............................ 本仓库的说明文档
```


## 关于 Front-matter

Hexo 的 Markdown 文章头部支持设置 `Front-matter` 区域，该区域的可选配置如下：

> 所有配置项均为**非必填**的，但仍然建议至少填写 `title` 和 `date` 的值

| 配置选项   | 默认值                      | 描述                                                         |
| ---------- | --------------------------- | ------------------------------------------------------------ |
| title      | `Markdown` 的文件标题        | 文章标题，强烈建议填写此选项                                 |
| date       | 文件创建时的日期时间          | 发布时间，强烈建议填写此选项，且最好保证全局唯一             |
| author     | 根 `_config.yml` 中的 `author` | 文章作者                                                     |
| img        | `featureImages` 中的某个值   | 文章特征图，推荐使用图床(腾讯云、七牛云、又拍云等)来做图片的路径.如: `http://xxx.com/xxx.jpg` |
| top        | `true`                      | 推荐文章（文章是否置顶），如果 `top` 值为 `true`，则会作为首页推荐文章 |
| cover      | `false`                     | `v1.0.2`版本新增，表示该文章是否需要加入到首页轮播封面中 |
| coverImg   | 无                          | `v1.0.2`版本新增，表示该文章在首页轮播封面需要显示的图片路径，如果没有，则默认使用文章的特色图片 |
| password   | 无                          | 文章阅读密码，如果要对文章设置阅读验证密码的话，就可以设置 `password` 的值，该值必须是用 `SHA256` 加密后的密码，防止被他人识破。前提是在主题的 `config.yml` 中激活了 `verifyPassword` 选项 |
| toc        | `true`                      | 是否开启 TOC，可以针对某篇文章单独关闭 TOC 的功能。前提是在主题的 `config.yml` 中激活了 `toc` 选项 |
| mathjax    | `false`                     | 是否开启数学公式支持 ，本文章是否开启 `mathjax`，且需要在主题的 `_config.yml` 文件中也需要开启才行 |
| summary    | 无                          | 文章摘要，自定义的文章摘要内容，如果这个属性有值，文章卡片摘要就显示这段文字，否则程序会自动截取文章的部分内容作为摘要 |
| categories | 无                          | 文章分类，本主题的分类表示宏观上大的分类，只建议一篇文章一个分类 |
| tags       | 无                          | 文章标签，一篇文章可以多个标签                              |
| keywords   | 文章标题                     | 文章关键字，SEO 时需要                              |
| reprintPolicy | cc_by                    | 文章转载规则， 可以是 cc_by, cc_by_nd, cc_by_sa, cc_by_nc, cc_by_nc_nd, cc_by_nc_sa, cc0, noreprint 或 pay 中的一个 |

**注意**:

1. 如果 `img` 属性不填写的话，文章特色图会根据文章标题的 `hashcode` 的值取余，然后选取主题中对应的特色图片，从而达到让所有文章都的特色图**各有特色**。
2. `date` 的值尽量保证每篇文章是唯一的，因为本主题中 `Gitalk` 和 `Gitment` 识别 `id` 是通过 `date` 的值来作为唯一标识的。
3. 如果要对文章设置阅读验证密码的功能，不仅要在 Front-matter 中设置采用了 SHA256 加密的 password 的值，还需要在主题的 `_config.yml` 中激活了配置。有些在线的 SHA256 加密的地址，可供你使用：[开源中国在线工具](http://tool.oschina.net/encrypt?type=2)、[chahuo](http://encode.chahuo.com/)、[站长工具](http://tool.chinaz.com/tools/hash.aspx)。
4. 可以在文章md文件的 front-matter 中指定 reprintPolicy 来给单个文章配置转载规则


最简示例：

```yaml
---
title: typora-vue-theme主题介绍
date: 2018-09-07 09:25:00
---
```

最全示例：

```yaml
---
title: 文章标题
date: 2018-09-07 09:25:00
author: EXP
img: /source/images/xxx.jpg
top: true
cover: true
coverImg: /images/1.jpg
password: 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
toc: false
mathjax: false
summary: 这是你自定义的文章摘要内容，如果这个属性有值，文章卡片摘要就显示这段文字，否则程序会自动截取文章的部分内容作为摘要
categories: Markdown
tags:
  - Typora
  - Markdown
---
```



## 参考文档

- 《[Hexo 指引手册](https://hexo.io/zh-cn/docs/)》
- 《[Hexo 主题列表](https://hexo.io/themes/)》
- 《[Hexo 目录结构](https://yuchen-lea.github.io/2016-01-18-hexo-dir-struct/)》
- 《[Github Pages部署个人博客（Hexo篇）](https://juejin.im/post/6844903590369181703)》
- 《[GitHub+Hexo 搭建个人网站详细教程](https://zhuanlan.zhihu.com/p/26625249)》
- 《[基于Docker的Hexo博客搭建](https://chunchengwei.github.io/ruan-jian/ji-yu-docker-de-hexo-bo-ke-da-jian/)》
- 《[基于Hexo的matery主题搭建博客并深度优化](https://juejin.im/post/6844904082042257415)》
- 《[Hexo 主题 Matery 配置](https://juejin.im/post/6844904147922190344)》
- 《[Hexo - 使文章依文章分類為資料夾名稱置放](https://usedfire.net/Notes/Hexo/make-hexo-post-category-by-folder/)》

