#!/bin/bash

name=${JOB_NAME}
image=$(cat ${WORKSPACE}/IMAGE)
host=${HOST}

echo "deploying name:${name}  image:${image}   host:${host}"

rm -rf web.yaml

cp $(dirname "${BASH_SOURCE[0]}")/template/web.yaml .
echo "准备copy"
sed -i "s,{{name}},${name},g" web.yaml
sed -i "s,{{image}},${image},g" web.yaml
sed -i "s,{{host}},${host},g" web.yaml
echo "准备apply"
kubectl apply -f web.yaml
echo "appay成功"
cat web.yaml



sleep 5

success=0
#健康检查
count=60
IFS=","
while [ ${count} -gt 0 ]
do 
	replicas=$( kubectl get deploy ${name} -o go-template='{{.status.replicas}},{{.status.updatedReplicas}},{{.status.readyReplicas}},{{.status.availableReplicas}}')
	echo "replicas:${replicas}"
	arr=(${replicas})
	
	if [ "${arr[0]}" == "${arr[1]}" -a "${arr[1]}" == "${arr[2]}" -a "${arr[2]}" == "${arr[3]}" ];then
		echo "health is success!"
		success=1
		break
	fi
	((count--))
	sleep 2
done

if [ ${success} -ne 1 ];then
	echo "health is failed"
	exit 1
fi
