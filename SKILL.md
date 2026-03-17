# APNs Push Skill

发送 iOS APNs 推送通知的 Skill。

## 功能
通过 Apple Push Notification service (APNs) 向 iOS 设备发送推送通知。

## 使用方法

### 交互式使用（推荐）

当你需要发送推送时，只需告诉 AI **"帮我发送 iOS 推送"** 或 **"发一条 APNs 推送"**，AI 会提示你提供以下信息：

**必需信息**（一次性提供）：
1. **P8 证书文件**：上传或提供 .p8 文件路径
2. **Team ID**：Apple Developer 账号的 Team ID（例如：569GNZ5392）
3. **Key ID**：P8 证书的 Key ID（例如：HB5S8B644A，通常可以从文件名获取）
4. **Bundle ID**：应用的 Bundle Identifier（例如：com.netease.NIM.demo）
5. **Device Token**：目标设备的 Device Token
6. **推送内容**：通知的标题和正文
7. **环境**：开发环境 (sandbox) 还是生产环境 (production)

**可选信息**（如不提供则使用默认值）：
- 角标数字 (badge)
- 通知音效 (sound)
- 通知类别 (category)
- 自定义数据 (custom_data)

### 示例对话

**用户**: 帮我发送一条 iOS 推送

**AI**: 好的，请一次性提供以下信息：
```
📱 iOS APNs 推送所需信息

【必需信息】
1. P8 证书文件：请上传 .p8 文件或提供文件路径
2. Team ID：Apple Developer 账号的 Team ID
3. Key ID：P8 证书的 Key ID
4. Bundle ID：应用的 Bundle Identifier
5. Device Token：目标设备的 Device Token
6. 推送内容：通知的标题和正文
7. 环境：sandbox (开发) 或 production (生产)

【可选信息】
- 角标数字 (badge)
- 通知音效 (sound，默认：default)
- 自定义 JSON 数据 (custom_data)
```

**用户**:
```
P8 证书：/path/to/APNsAuthKey.p8
Team ID: 569GNZ5392
Key ID: HB5S8B644A
Bundle ID: com.netease.NIM.demo
Device Token: 61f7fa70a44eae014f86bc7a2c2c21e4e4455f6badd6130c14dc97355aab8434
推送内容：你好，这是一条测试推送
环境：sandbox
```

**AI**: 正在发送推送... ✅ 推送发送成功！

### 命令行直接调用

```bash
bash ${SKILLS_ROOT:-/workspace/skills}/apns-push/send_push.sh \
  --p8_path "/path/to/APNsAuthKey.p8" \
  --team_id "569GNZ5392" \
  --key_id "HB5S8B644A" \
  --bundle_id "com.netease.NIM.demo" \
  --device_token "61f7fa70a44eae014f86bc7a2c2c21e4e4455f6badd6130c14dc97355aab8434" \
  --alert_content "你好，这是一条推送通知" \
  --environment "sandbox"
```

## 参数说明

| 参数 | 必需 | 说明 | 示例 |
|------|------|------|------|
| `--p8_path` | ✓ | P8 证书文件路径 | `/path/to/APNsAuthKey.p8` |
| `--team_id` | ✓ | Apple Team ID | `569GNZ5392` |
| `--key_id` | ✓ | P8 Key ID | `HB5S8B644A` |
| `--bundle_id` | ✓ | 应用 Bundle ID | `com.example.app` |
| `--device_token` | ✓ | 设备 Token | `61f7fa...` |
| `--alert_content` | ✓ | 推送标题和正文 | `你好` |
| `--environment` | ✓ | sandbox 或 production | `sandbox` |
| `--badge` |  | 角标数字 | `5` |
| `--sound` |  | 通知音效 | `default` |
| `--category` |  | 通知类别 | `MESSAGE_CATEGORY` |
| `--custom_data` |  | 自定义 JSON 数据 | `{"type":"message"}` |

## 错误处理
- 返回 HTTP 200 表示推送发送成功
- 返回其他状态码表示失败，常见错误：
  - 400: 请求格式错误
  - 403: 证书无效或权限不足
  - 410: Device Token 已失效
