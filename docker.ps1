$REPO="danrossi/gstreamer"
$IMAGE="gst-build-cross"
$VERSION="latest"
$WORKDIR="/build"
$ID = $env:username

#-u $(id -u):$(id -g) 
#docker run -dit --name ${IMAGE} -m 16g  --memory-swap="20g" --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} ${REPO}/${IMAGE}:${VERSION} /bin/bash
docker run -dit --name ${IMAGE}1 --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} ${REPO}/${IMAGE}:${VERSION} /bin/bash