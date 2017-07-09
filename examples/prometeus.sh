# discover all metrics labels
curl -g 'http://yzamir-centos7-3.eng.lab.tlv.redhat.com/api/v1/label/__name__/values' | python -m json.too

# discover all metrics with specific label
# get raw values
curl -g 'http://yzamir-centos7-3.eng.lab.tlv.redhat.com/api/v1/query?query=container_memory_usage_bytes' | python -m json.tool

# discover all metrics with specific label
# get data buckets
curl 'http://yzamir-centos7-3.eng.lab.tlv.redhat.com/api/v1/query_range?query=container_memory_usage_bytes&start=2017-05-08T00:00:00.000Z&end=2017-05-08T20:00:00.000Z&step=15m' | python -m json.tool

# get data bucekts for specific ID ( with URL encoding )
curl -G 'http://yzamir-centos7-3.eng.lab.tlv.redhat.com/api/v1/query_range' --data-urlencode 'query=container_memory_usage_bytes{id="/system.slice/docker-f39e05e9a3445b4fe8b0777f27a493230bd9e750d0a9da6a602af3c58f22bb67.scope"}&start=2017-05-08T00:00:00.000Z&end=2017-05-08T20:00:00.000Z&step=15m'

# with bearer
curl -k 'https://prometheus.10.35.19.248.nip.io/api/v1/label/__name__/values' -H "Authorization: Bearer ${TOKEN}" | jq

curl 'http://yzamir-centos7-3.eng.lab.tlv.redhat.com/api/v1/query?query=container_memory_usage_bytes' | jq
curl -k 'https://prometheus.10.35.19.248.nip.io/api/v1/query?query=container_memory_usage_bytes' -H "Authorization: Bearer ${TOKEN}" | jq

curl 'http://yzamir-centos7-3.eng.lab.tlv.redhat.com/api/v1/query_range?query=container_memory_usage_bytes&start=2017-05-08T00:00:00.000Z&end=2017-05-08T20:00:00.000Z&step=15m' | jq
curl -k 'https://prometheus.10.35.19.248.nip.io/api/v1/query_range?query=container_memory_usage_bytes&start=2017-05-08T00:00:00.000Z&end=2017-05-08T20:00:00.000Z&step=15m' | jq
