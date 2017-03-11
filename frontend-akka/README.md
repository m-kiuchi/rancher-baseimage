# dockerfiles m-kiuchi/frontend-akka

# Building & Running(jp)

## Build

コンテナは以下の方法でビルドします

```shell
# docker build --rm -t m-kiuchi/frontend-akka .
```

## Run

以下のように実行します

```shell
# docker run -d -p 22 -p 8888 m-kiuchi/frontend-akka
```

## コンテナにsshログインする

実行後sshでログインするためのデフォルトユーザは `root` になります。パスワードは実行のたびに新たに生成されます。 `docker logs` コマンドで確認してください。

```shell
# docker logs <コンテナID>
Changing password for user root.
passwd: all authentication tokens updated successfully.
--------------------
 SSH PASSWORD - please change immediately
 username: root , password: 4ee246bfcffae1984d56ba77543d3390685f47a0
--------------------
```

rootユーザでログインしたくない場合、以下のように実行します。

```shell
# docker run -d -p 22 -p 8888 m-kiuchi/frontend-akka <ユーザ名>
```

root以外のユーザでsshログインした場合は、ログイン後 `sudo` コマンドで管理者コマンドを実行することができます

コンテナID, ポート番号を確認するためには `docker ps` コマンドを使用します。

```shell
# docker ps
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS              PORTS                   NAMES
8c82a9287b23        m-kiuchi/frontend-akka   /start.sh   4 seconds ago       Up 2 seconds        0.0.0.0:49153->8888/tcp, 0.0.0.0:49154->22/tcp   mad_mccarthy        
```

sshでコンテナにログインするには以下のコマンドを実行します

```shell
# ssh -l root -p xxxx localhost
```

## Lightbend Activatorを起動する

```shell
$ activator ui -Dhttp.address=0.0.0.0
```

ブラウザからコンテナのポート番号8888(ホスト側ではリダイレクトされて他のポート番号になっています)を開きます

# Building & Running(en)

## Build

Copy the sources to your docker host and build the container:

```shell
# docker build --rm -t m-kiuchi/frontend-akka .
```

## Run

To run:

```shell
# docker run -d -p 22 -p 8888 m-kiuchi/frontend-akka
```

Default user name is `root` and default password is changed for each `docker run` . Please check `docker logs` .

```shell
# docker logs <container id>
Changing password for user root.
passwd: all authentication tokens updated successfully.
--------------------
 SSH PASSWORD - please change immediately
 username: root , password: 4ee246bfcffae1984d56ba77543d3390685f47a0
--------------------
```

If you want to log in to container as specified username instead of default user `root`, please run following:

```shell
# docker run -d -p 22 -p 8888 m-kiuchi/frontend-akka <your user name>
```

After log in, you can promote to root as `sudo`.

Get the port that the container is listening on:

```shell
# docker ps
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS              PORTS                   NAMES
8c82a9287b23        m-kiuchi/frontend-akka   /start.sh   4 seconds ago       Up 2 seconds        0.0.0.0:49153->8888/tcp, 0.0.0.0:49154->22/tcp   mad_mccarthy        
```

## ssh log into container

To test, use the port that was just located:

```shell
$ ssh -l root -p xxxx <address>
```

## Run Lightbend Activator

```shell
$ activator ui -Dhttp.address=0.0.0.0
```

Open your http://<host>:<port> . port is the source port which is redirected to container's port 8888.
