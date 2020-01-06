curl -s --cacert ca.crt --header "Authorization: Bearer $(cat token.txt)" $(cat url.txt)/healthz
