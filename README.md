# Seichi Cloudflare Terraform

整地鯖のアクセスポリシーを Cloudflare で管理するための Terraform ファイルを管理しているリポジトリです。

Argo Tunnel がガバだと困るのでポリシーを設定したいけど手動で管理すると大変なので Terraform でやってみるかという話になって作ったやつ。

tfstate の管理はまともにやると大変なので Terraform Cloud で丸投げしてしまおうとなっているが、ユーザー数がかなり制限厳しいのでどうしようかね。
