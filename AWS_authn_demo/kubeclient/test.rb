#!/usr/bin/env ruby

require "kubeclient"

cert_store = OpenSSL::X509::Store.new
cert_store.add_cert(OpenSSL::X509::Certificate.new(File.read('./ca.crt')))
ssl_options = {
  cert_store: cert_store,
  verify_ssl: OpenSSL::SSL::VERIFY_PEER
}
auth_options = {
  bearer_token_file: './token.txt'
}
client = Kubeclient::Client.new(
  'https://api.aamoc4.cyberarkdemo.com:6443', "v1", ssl_options: ssl_options, auth_options: auth_options
)

#puts client.get_pods(namespace: 'cyberark')
puts client.get_services(namespace: 'cyberark')
