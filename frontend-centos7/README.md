# dockerfiles m-kiuchi/frontend-centos7

# Building & Running(jp)

コンテナは以下の方法でビルドします

	# docker build --rm -t m-kiuchi/frontend-centos7 .

以下のように実行します

	# docker run -d -p 22 m-kiuchi/frontend-centos7

実行後sshでログインするためのデフォルトユーザは `root` になります。パスワードは実行のたびに新たに生成されます。 `docker logs` コマンドで確認してください。

    # docker logs <コンテナID>
	Changing password for user root.
	passwd: all authentication tokens updated successfully.
	--------------------
	 SSH PASSWORD - please change immediately
	 username: root , password: 4ee246bfcffae1984d56ba77543d3390685f47a0
	--------------------
	Could not load host key: /etc/ssh/ssh_host_ecdsa_key
	Could not load host key: /etc/ssh/ssh_host_ed25519_key

rootユーザでログインしたくない場合、以下のように実行します。

	# docker run -d -p 22 m-kiuchi/frontend-centos7 <ユーザ名>

root以外のユーザでsshログインした場合は、ログイン後 `sudo` コマンドで管理者コマンドを実行することができます

コンテナID, ポート番号を確認するためには `docker ps` コマンドを使用します。

```
# docker ps
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS              PORTS                   NAMES
8c82a9287b23        m-kiuchi/frontend-centos7   /start.sh   4 seconds ago       Up 2 seconds        0.0.0.0:49154->22/tcp   mad_mccarthy        
```

sshでコンテナにログインするには以下のコマンドを実行します

	# ssh -l root -p xxxx localhost


# Building & Running(en)

Copy the sources to your docker host and build the container:

	# docker build --rm -t m-kiuchi/frontend-centos7 .

To run:

	# docker run -d -p 22 m-kiuchi/frontend-centos7

Default user name is `root` and default password is changed for each `docker run` . Please check `docker logs` .

If you want to log in to container as specified username instead of default user `root`, please run following:

	# docker run -d -p 22 m-kiuchi/frontend-centos7 <your user name>

After log in, you can promote to root as `sudo`.

Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS              PORTS                   NAMES
8c82a9287b23        m-kiuchi/frontend-centos7   /start.sh   4 seconds ago       Up 2 seconds        0.0.0.0:49154->22/tcp   mad_mccarthy        
```

To test, use the port that was just located:

	# ssh -l root -p xxxx localhost
