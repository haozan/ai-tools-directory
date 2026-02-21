# Kulawyer (酷律师)

Kulawyer - 发现最佳法律AI工具平台

探索强大的法律AI工具,提升工作效率。从AI法律文书撰写到案例分析，Kulawyer为您的法律工作找到最合适的AI助手。

## About

This project is built with ClackyAI Rails7 starter template.

## Installation

Install dependencies:

* postgresql

    ```bash
    $ brew install postgresql
    ```

    Ensure you have already initialized a user with username: `postgres` and password: `postgres`( e.g. using `$ createuser -d postgres` command creating one )

* rails 7

    Using `rbenv`, update `ruby` up to 3.x, and install `rails 7.x`

    ```bash
    $ ruby -v ( output should be 3.x )

    $ gem install rails

    $ rails -v ( output should be rails 7.x )
    ```

* npm

    Make sure you have Node.js and npm installed

    ```bash
    $ npm --version ( output should be 8.x or higher )
    ```

Install dependencies, setup db:
```bash
$ ./bin/setup
```

Start it:
```
$ bin/dev
```

## Admin dashboard info

This template already have admin backend for website manager, do not write business logic here.

Access url: /admin

Default superuser: admin

Default password: admin

### 数据同步功能

后台管理系统提供一键数据同步功能，可将本地数据同步到生产环境：

1. **导出数据**：`rails runner tmp/export_current_data.rb`
2. **部署后同步**：登录后台 → Dashboard → 点击 "Sync Data" 按钮

详细说明请查看：
- 快速指南：[docs/deployment_sync_checklist.md](docs/deployment_sync_checklist.md)
- 完整文档：[docs/data_sync_guide.md](docs/data_sync_guide.md)

## Tech stack

* Ruby on Rails 7.x
* Tailwind CSS 3 (with custom design system)
* Hotwire Turbo (Drive, Frames, Streams)
* Stimulus
* ActionCable
* figaro
* postgres
* active_storage
* kaminari
* puma
* rspec