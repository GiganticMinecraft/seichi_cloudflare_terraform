# VPSからオンプレに繋ぐための(Cloudflare tunnelを経由する)TCPネットワーク
resource "cloudflare_access_application" "debug_vps_to_op_network" {
  zone_id                   = local.cloudflare_zone_id
  name                      = "Debug Network"
  domain                    = "*.tcp-debug-network.${local.root_domain}"
  type                      = "self_hosted"
  # オンプレ側が1日に1回再起動するのでセッション長は高々24時間になる
  session_duration          = "30h"
}

resource "cloudflare_access_service_token" "debug_linode_to_onp" {
  zone_id    = local.cloudflare_zone_id
  name       = "Linode (for Debug Network)"

  # 30日でexpireするように設定しておく。
  # TODO: GitHub Actions等で20日に一度 terraform apply されるようにしたい
  min_days_for_renewal = 30

  lifecycle {
    # terafform apply 等をしたときにリソースが必ず再生成されるようにする(トークンのvalidityを伸ばすようにする)
    create_before_destroy = true
  }
}

resource "cloudflare_access_policy" "debug_linode_to_onp" {
  application_id = cloudflare_access_application.debug_vps_to_op_network.id
  zone_id        = local.cloudflare_zone_id
  name           = "Require service token for access"
  precedence     = "1"
  # allow/deny での制御にすると、クライアントとなるcloudflaredが起動するときにブラウザ経由の認証を求められる。
  # Service account token による制御ではそんなことは無いが、 decision を non_identity とする必要がある。
  # 詳細は https://developers.cloudflare.com/cloudflare-one/policies/zero-trust#actions を参照のこと
  decision       = "non_identity"

  include {
    service_token = [
      cloudflare_access_service_token.debug_linode_to_onp.id
    ]
  }
}