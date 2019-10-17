#!/bin/bash
file=$1
echo "ipa file is $file"
if [ "$file" != "" ];then
	echo "Begin upload!"
	echo $file
	# ipa distribute:pgyer -u 8d4ea56e591b5173dfe854e39bb0e6b0 -a 244725993607ed36e3a9fbeb603c0ba3 -f ${file}
	# ipa distribute:fir -u 0abd87958fd7a40077dcf57800f2cf2b -a 559e0237692d797c97000040 -f ${file}

	#fir publish ${file} # 如果fir没有登录 手动使用 fir login 输入token 0abd87958fd7a40077dcf57800f2cf2b
	
	curl -F "file=@$file" -F "uKey=2be78849b359b507ffbe041870914554" -F "_api_key=d7209b77d391a18cceb321e4add62cae" http://www.pgyer.com/apiv1/app/upload
	#http://www.pgyer.com/apiv1/app/upload
else
	echo "ipa file is empty."
fi
