# e.g. script/create_certs.sh oset-mi
# OSET Certificate Authority (CA) - private key
openssl genrsa -out $1-ca.key 4096
# CA Certificate - public key + meta
openssl req -new -x509 -days 365 -key $1-ca.key -out $1-ca.crt
# OSET's client (private) key
openssl genrsa -out $1.key 4096
# Client's Certificate Signing Request request
openssl req -new -key $1.key -out $1.csr
# Client certificate signed by OSET's CA 
openssl x509 -req -days 365 -in $1.csr -CA $1-ca.crt -CAkey $1-ca.key -set_serial 01 -out $1.crt

# Convert certs to pfx https://stackoverflow.com/questions/6307886/how-to-create-pfx-file-from-certificate-and-private-key

openssl pkcs12 -export -out $1.pfx -inkey $1.key -in $1-ca.crt -in $1.crt