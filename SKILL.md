# APNs Push Skill

发送 iOS APNs 推送通知的 Skill。

## 功能
通过 Apple Push Notification service (APNs) 向 iOS 设备发送推送通知。

## 使用方法

### 必需参数
- **p8_path**: P8 证书文件的绝对路径
- **team_id**: Apple Developer Team ID（例如：569GNZ5392）
- **key_id**: P8 证书的 Key ID（例如：HB5S8B644A）
- **bundle_id**: 应用的 Bundle Identifier（例如：com.netease.NIM.demo）
- **device_token**: 目标设备的 Device Token
- **alert_content**: 推送通知的标题和正文内容
- **environment**: 环境类型，可选值：`sandbox`（开发）或 `production`（生产）

### 可选参数
- **badge**: 应用图标角标数字（默认不设置）
- **sound**: 通知音效（默认：default）
- **category**: 通知类别（用于交互式通知）
- **custom_data**: 自定义 JSON 数据

## 示例

### 基本用法
```bash
# 开发环境推送
bash ${SKILLS_ROOT:-/workspace/skills}/apns-push/send_push.sh \
  --p8_path "/path/to/APNsAuthKey.p8" \
  --team_id "569GNZ5392" \
  --key_id "HB5S8B644A" \
  --bundle_id "com.netease.NIM.demo" \
  --device_token "61f7fa70a44eae014f86bc7a2c2c21e4e4455f6badd6130c14dc97355aab8434" \
  --alert_content "你好，这是一条推送通知" \
  --environment "sandbox"
```

### 生产环境推送
```bash
bash ${SKILLS_ROOT:-/workspace/skills}/apns-push/send_push.sh \
  --p8_path "/path/to/APNsAuthKey.p8" \
  --team_id "569GNZ5392" \
  --key_id "HB5S8B644A" \
  --bundle_id "com.example.app" \
  --device_token "device_token_here" \
  --alert_content "生产环境推送" \
  --environment "production"
```

### 带自定义数据
```bash
bash ${SKILLS_ROOT:-/workspace/skills}/apns-push/send_push.sh \
  --p8_path "/path/to/APNsAuthKey.p8" \
  --team_id "569GNZ5392" \
  --key_id "HB5S8B644A" \
  --bundle_id "com.example.app" \
  --device_token "device_token_here" \
  --alert_content "带数据的推送" \
  --environment "sandbox" \
  --badge "5" \
  --sound "default" \
  --custom_data '{"type":"message","messageId":"12345"}'
```

## 错误处理
- 返回 HTTP 200 表示推送发送成功
- 返回其他状态码表示失败，常见错误：
  - 400: 请求格式错误
  - 403: 证书无效或权限不足
  - 410: Device Token 已失效
