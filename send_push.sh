#!/bin/bash

# APNs Push Notification Script
# 发送 iOS APNs 推送通知

set -e

# 默认值
ENVIRONMENT="sandbox"
BADGE=""
SOUND="default"
CATEGORY=""
CUSTOM_DATA=""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
使用方法：$0 [选项]

必需参数:
  --p8_path         P8 证书文件的绝对路径
  --team_id         Apple Developer Team ID
  --key_id          P8 证书的 Key ID
  --bundle_id       应用的 Bundle Identifier
  --device_token    目标设备的 Device Token
  --alert_content   推送通知的标题和正文内容
  --environment     环境类型：sandbox (开发) 或 production (生产)，默认：sandbox

可选参数:
  --badge           应用图标角标数字
  --sound           通知音效，默认：default
  --category        通知类别（用于交互式通知）
  --custom_data     自定义 JSON 数据

示例:
  $0 --p8_path "/path/to/key.p8" --team_id "569GNZ5392" --key_id "HB5S8B644A" \\
     --bundle_id "com.example.app" --device_token "device_token" \\
     --alert_content "你好" --environment "sandbox"
EOF
    exit 1
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --p8_path)
            P8_PATH="$2"
            shift 2
            ;;
        --team_id)
            TEAM_ID="$2"
            shift 2
            ;;
        --key_id)
            KEY_ID="$2"
            shift 2
            ;;
        --bundle_id)
            BUNDLE_ID="$2"
            shift 2
            ;;
        --device_token)
            DEVICE_TOKEN="$2"
            shift 2
            ;;
        --alert_content)
            ALERT_CONTENT="$2"
            shift 2
            ;;
        --environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --badge)
            BADGE="$2"
            shift 2
            ;;
        --sound)
            SOUND="$2"
            shift 2
            ;;
        --category)
            CATEGORY="$2"
            shift 2
            ;;
        --custom_data)
            CUSTOM_DATA="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}未知参数：$1${NC}"
            usage
            ;;
    esac
done

# 验证必需参数
missing_params=()
[[ -z "$P8_PATH" ]] && missing_params+=("p8_path")
[[ -z "$TEAM_ID" ]] && missing_params+=("team_id")
[[ -z "$KEY_ID" ]] && missing_params+=("key_id")
[[ -z "$BUNDLE_ID" ]] && missing_params+=("bundle_id")
[[ -z "$DEVICE_TOKEN" ]] && missing_params+=("device_token")
[[ -z "$ALERT_CONTENT" ]] && missing_params+=("alert_content")

if [[ ${#missing_params[@]} -gt 0 ]]; then
    echo -e "${RED}错误：缺少必需参数：${missing_params[*]}${NC}"
    usage
fi

# 验证 P8 文件是否存在
if [[ ! -f "$P8_PATH" ]]; then
    echo -e "${RED}错误：P8 证书文件不存在：$P8_PATH${NC}"
    exit 1
fi

# 设置 APNs 端点
if [[ "$ENVIRONMENT" == "production" ]]; then
    APNS_URL="https://api.push.apple.com"
    echo -e "${YELLOW}使用生产环境${NC}"
else
    APNS_URL="https://api.sandbox.push.apple.com"
    echo -e "${YELLOW}使用开发环境 (sandbox)${NC}"
fi

echo ""
echo "=== APNs 推送信息 ==="
echo "Team ID:      $TEAM_ID"
echo "Key ID:       $KEY_ID"
echo "Bundle ID:    $BUNDLE_ID"
echo "Device Token: $DEVICE_TOKEN"
echo "推送内容：    $ALERT_CONTENT"
echo "环境：        $ENVIRONMENT"
echo ""

# 生成 JWT Token
echo "正在生成 JWT Token..."
CLAIMS=$(printf '{"iss":"%s","iat":%d}' "$TEAM_ID" "$(date +%s)")
HEADER=$(printf '{"alg":"ES256","kid":"%s"}' "$KEY_ID" | base64 | tr -d '\n=' | tr '/+' '_-')
CLAIMS_B64=$(echo -n "$CLAIMS" | base64 | tr -d '\n=' | tr '/+' '_-')

SIGNING_INPUT="$HEADER.$CLAIMS_B64"
SIGNATURE=$(echo -n "$SIGNING_INPUT" | openssl dgst -binary -sha256 -sign "$P8_PATH" | base64 | tr -d '\n=' | tr '/+' '_-')

TOKEN="$HEADER.$CLAIMS_B64.$SIGNATURE"

# 构建推送 Payload
if [[ -n "$BADGE" ]]; then
    BADGE_PART=",\"badge\":$BADGE"
else
    BADGE_PART=""
fi

if [[ -n "$CATEGORY" ]]; then
    CATEGORY_PART=",\"category\":\"$CATEGORY\""
else
    CATEGORY_PART=""
fi

if [[ -n "$CUSTOM_DATA" ]]; then
    CUSTOM_PART=",$CUSTOM_DATA"
else
    CUSTOM_PART=""
fi

PAYLOAD=$(cat << EOF
{
  "aps": {
    "alert": {
      "title": "$ALERT_CONTENT",
      "body": "$ALERT_CONTENT"
    },
    "sound": "$SOUND"$BADGE_PART$CATEGORY_PART,
    "content-available": 1
  }$CUSTOM_PART
}
EOF
)

echo "正在发送推送..."
echo ""

# 发送推送请求
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -d "$PAYLOAD" \
  -H "apns-topic: $BUNDLE_ID" \
  -H "apns-push-type: alert" \
  -H "apns-priority: 10" \
  -H "authorization: bearer $TOKEN" \
  -H "apns-expiration: 0" \
  --http2 \
  "$APNS_URL/3/device/$DEVICE_TOKEN"
)

# 提取 HTTP 状态码（最后一行）
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo ""
echo "=== 推送结果 ==="

if [[ "$HTTP_CODE" == "200" ]]; then
    echo -e "${GREEN}✓ 推送发送成功！${NC}"
    echo "HTTP 状态码：$HTTP_CODE"
    exit 0
else
    echo -e "${RED}✗ 推送发送失败！${NC}"
    echo "HTTP 状态码：$HTTP_CODE"
    if [[ -n "$RESPONSE_BODY" ]]; then
        echo "响应内容：$RESPONSE_BODY"
    fi
    exit 1
fi
