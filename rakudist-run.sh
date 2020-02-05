token=$(curl -s -d os=alpine -d project=melezhik/sparrowdo http://repo.westus.cloudapp.azure.com/rakudist/api/run/:github)
while true; do
  status=$(curl -s -d token=$token http://repo.westus.cloudapp.azure.com/rakudist/api/job/status)
  sleep 5
  echo $status
  if [ $status != "running" ]; then
    break
  fi
done
echo "test: $status"
curl -L -s -d token=$token http://repo.westus.cloudapp.azure.com/rakudist/api/job/report
if [ $status != "success" ]; then
  exit 1
fi

