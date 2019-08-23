#!/bin/bash -x

dex="docker exec -it conjur1"

main() {
  encrypt_keys
  sleep 2
  check_health
  docker stop conjur1

  docker start conjur1
  sleep 5
  check_health
  docker logs conjur1
exit
  decrypt_keys
  sleep 5
  check_health
}

encrypt_keys() {
  $dex sv stop conjur nginx pg
  $dex evoke keys lock
  openssl rand 32 > ./master-key
  cat ./master-key | $dex evoke keys encrypt -
  cat ./master-key | $dex evoke keys unlock -
  $dex sv start pg nginx conjur
}

check_health() {
  curl -k https://conjur-master:30443/health
}

decrypt_keys() {
  cat ./master-key | $dex evoke keys decrypt-all -
}

main "$@"
