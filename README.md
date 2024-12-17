# DevSpaceを使った開発環境構築

k9sなんかも便利

## DevSpaceとは

Kubernetesによるローカル開発を支援するツールです。類似のツールには[Skaffold](https://skaffold.dev/)などがあります。

ざっくり言えばローカルKubernetes環境において、docker-composeの代わりになるものと考えると良いと思います。

## 環境整備手順

### ローカルKubernetes環境の準備

Docker Desktop for Mac を使っている場合は、設定画面からビルトインのkubernetesを有効にすれば終わりです。

**Virtual Disk Limitを多めに取っておかないとコンテナイメージのビルド時に謎に落ちるので注意してください。** (200GBくらいに上げておきましょう。)


### DevSpaceのインストール

Node.jsが入っている場合は `npm install -g devspace`

macOSではbrewでインストール可能です。

```
brew install devspace
```

## DevSpaceの起動

```
devspace dev --namespace sample
```

で起動します。

起動がうまくいくと、ホスト側のディレクトリツリーをpod内に同期する処理が開始されます。

もしうまくメッセージが出力されない場合には、

```
devspace purge --namespace sample
```

で一旦立ち上がったpodを削除してやり直してみてください。

```
# 全部消す
kubectl delete daemonsets,replicasets,services,deployments,pods,rc,ing --all -n sample
```

### ビルドの省略

```
devspace dev --namespace sample --skip-build
```

ref. https://www.devspace.sh/docs/configuration/dev/connections/file-sync

## devproxy経由での接続

devproxyはserviceとしてNodePort経由で公開されています。

```
$ kubectl get services -n sample devproxy
NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
devproxy                 NodePort    10.111.115.211   <none>        8080:30080/TCP      2m2s
```

kubectlコマンドなどでホスト側のポートが何であるかを確認し、ブラウザのプロキシ設定を適宜変更してください。

上記の例では `30080` となります。

## local helm

```
$helm install -f helm-values.local.yaml app charts/sample-app/ -n sample
NAME: app
LAST DEPLOYED: Fri Mar  1 18:20:37 2024
NAMESPACE: sample
STATUS: deployed
REVISION: 1
# 2回目以降
$helm upgrade -f helm-values.local.yaml app charts/sample-app/ -n sample
# 削除
$helm uninstall app -n sample
```
