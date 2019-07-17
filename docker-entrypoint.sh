#!/bin/dash
set -e

if [ ! -s "$BITCOIN_DATA/bitcoin.conf" ]; then
	cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
	txindex=1
	printtoconsole=1
	rpcallowip=::/0
	rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
	rpcuser=${BITCOIN_RPC_USER:-omni}
	EOF
fi

exec "$@"
