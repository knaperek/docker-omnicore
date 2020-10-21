FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget \
	&& rm -rf /var/lib/apt/lists/*

ENV OMNI_VERSION=0.9.0
ENV	OMNI_URL=https://github.com/OmniLayer/omnicore/releases/download/v$OMNI_VERSION/omnicore-$OMNI_VERSION-x86_64-linux-gnu.tar.gz \
	OMNI_SHA256=70adddaff52e597975fa5ebee1642be95664f21c7e356d5c931dc4ea8a112fb9

RUN set -ex \
	&& cd /tmp \
	&& wget -qO omnicore.tar.gz "$OMNI_URL" \
	&& echo "$OMNI_SHA256 omnicore.tar.gz" | sha256sum -c - \
	&& tar -xzvf omnicore.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt


FROM debian:stretch-slim
COPY --from=builder /usr/local/bin/omnicored /usr/local/bin/omnicore-cli /usr/local/bin/
RUN groupadd -r omni && useradd -r -m -g omni omni \
	&& ln -s /usr/local/bin/omnicore-cli /usr/local/bin/c

# Omni uses Bitcoin Core's datadir (it is an extension of Bitcoin Core after all)
ENV BITCOIN_DATA=/data

# create data directory
RUN mkdir "$BITCOIN_DATA" \
	&& chown -R omni:omni "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/omni/.bitcoin \
	&& chown -h omni:omni /home/omni/.bitcoin

VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh

USER omni

ENTRYPOINT ["/entrypoint.sh"]
CMD ["omnicored"]
