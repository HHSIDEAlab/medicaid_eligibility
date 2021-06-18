docker build -f Dockerfile -t $2:$1 .
docker push $2:$1
