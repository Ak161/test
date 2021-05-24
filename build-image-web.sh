#/bin/bash

if [  "${BUILD_DIR}" == "" ];then
	echo "env  'BUILD_DIR' IS NOT SET"
	exit 1
fi

DOCKER_DIR=${BUILD_DIR}/${JOB_NAME}
if [ ! -d ${DOCKER_DIR} ];then
	mkdir -p ${DOCKER_DIR}
fi

echo "docker workspace :  ${DOCKER_DIR}"

JENKINS_DIR=${WORKSPACE}/${MODULE}

echo "jenkins workspace : ${JENKINS_DIR}"

if [ ! -f ${JENKINS_DIR}/target/*.jar ];then
	echo "targer jar file not found : ${JENKINS_DIR}/target/*.tar"
	exit 1
fi

cd ${DOCKER_DIR}

rm -rf *

if [ ! -d ${JENKINS_DIR}/ROOT ];then
        echo "创建Dockerfile下ROOT目录成功"
        mkdir ROOT
fi

mv ${JENKINS_DIR}/target/*.jar ROOT/

mv ${JENKINS_DIR}/Dockerfile . 

if [ -d ${JENKINS_DIR}/dockerfiles ];then
	echo "aaaaaaaaaaaaaaaaaaa"
	mv ${JENKINS_DIR}/dockerfiles .
fi

if [ $? -eq 0 ];then
	echo "bbbbbbbbbbbbbbbbbbb"
fi

VERSION=$(date +%Y%m%d%H%M%S)

IMAGES_NAME=www.harbor.com/kubernetes/${JOB_NAME}:${VERSION}

echo "${IMAGES_NAME}" > ${WORKSPACE}/IMAGE
echo "building image: ${IMAGES_NAME}"

docker build -t ${IMAGES_NAME} .


docker push ${IMAGES_NAME}
