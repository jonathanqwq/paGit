#!/bin/bash

# 配置 / Configuration

# 您的Email / Your Email
GIT_EMAIL="somebody@somewhere.com"

# 您的英文名 / Your Name
GIT_UNAME="somebody"

# 您仓库的"克隆/下载(Clone or download)"链接
# 您会从您使用的网站得到一个格式类似的地址
# 请原样复制过来
# The "Clone or download" url of your repository
# Just look for a button that says it on that page
# And you should see a link when you clicks it
HTTPS_PROVIDER="https://git??.com/somebody/somewhere.git"

# 您的github/gitee注册时使用的邮箱 / Your github/gitee Email address for registration
HTTPS_USERNAME="somebody@somewhere.com"

# 您的github/gitee密码 / Your github/gitee password
HTTPS_PASSWORD="something"



COMMIT_MSG="使用pagit上传"
HTTPS_USERNAME=$(echo $HTTPS_USERNAME | tr -d '\n' | xxd -plain | sed 's/\(..\)/%\1/g')
HTTPS_PASSWORD=$(echo $HTTPS_PASSWORD | tr -d '\n' | xxd -plain | sed 's/\(..\)/%\1/g')
HTTPS_PROVIDER=$(echo $HTTPS_PROVIDER | sed s#://#://$HTTPS_USERNAME:$HTTPS_PASSWORD@#)
echo $HTTPS_PROVIDER
if [ ! -d .git ]; then
	git init
	git config user.name $GIT_UNAME
	git config user.email $GIT_EMAIL
fi
if [ -z $(git remote) ]; then
	git remote add origin $HTTPS_PROVIDER
fi
pmg=$(git pull --set-upstream origin master 2>&1); pst=$?
echo $pmg | grep "couldn't find remote ref master" >/dev/null; echo $pmg
if [ $pst != 0 -a $? != 0 ]; then
	echo -e "\033[31m 发生合并冲突. 请手动解决! \033[0m"
	echo -e "\033[31m Merge conflict. Please resolve it manually! \033[0m"
	exit
fi
grep "pagit.sh" .gitignore >/dev/null
if [ $? != 0 ]; then echo "pagit.sh" >>.gitignore; fi
git add .
if git commit -m "$COMMIT_MSG"; then
	git push origin master
	echo -e "\033[32m 上传完成. 谢谢! \033[0m"
	echo -e "\033[32m Commit succeed. Thank you! \033[0m"
	if echo $HTTPS_PROVIDER | grep "gitee.com" >/dev/null; then
		echo -e "\033[33m 上传完成.如果您使用此工具修改pages文件，请勿忘记在码云网站上手动更新Pages. \033[0m"
		echo -e "\033[33m Upload completed. If you use this tool to modify the pages file, please do not forget to manually update pages on code cloud website \033[0m"
	fi
else
	echo -e "\033[33m 没有文件变动. \033[0m"
	echo -e "\033[33m No file was updated. \033[0m"
fi
if [ $# == 0 ]; then read -n 1; fi
