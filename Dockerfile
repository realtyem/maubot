FROM node:18 AS frontend-builder

COPY ./maubot/management/frontend /frontend
RUN cd /frontend && yarn --prod && yarn build

FROM alpine:3.18

RUN apk add --no-cache python3
RUN apk add --no-cache py3-pip
RUN apk add --no-cache py3-setuptools
RUN apk add --no-cache py3-wheel
RUN apk add --no-cache ca-certificates
RUN apk add --no-cache su-exec
RUN apk add --no-cache yq
RUN apk add --no-cache py3-aiohttp
RUN apk add --no-cache py3-sqlalchemy
RUN apk add --no-cache py3-attrs
RUN apk add --no-cache py3-bcrypt
RUN apk add --no-cache py3-cffi
RUN apk add --no-cache py3-ruamel.yaml
RUN apk add --no-cache py3-jinja2
RUN apk add --no-cache py3-click
RUN apk add --no-cache py3-packaging
RUN apk add --no-cache py3-markdown
RUN apk add --no-cache py3-alembic
RUN apk add --no-cache py3-cssselect
RUN apk add --no-cache py3-commonmark
RUN apk add --no-cache py3-pygments
RUN apk add --no-cache py3-tz
RUN apk add --no-cache py3-regex
RUN apk add --no-cache py3-wcwidth
        # encryption
RUN apk add --no-cache py3-cffi
RUN apk add --no-cache py3-olm
RUN apk add --no-cache py3-pycryptodome
RUN apk add --no-cache py3-unpaddedbase64
RUN apk add --no-cache py3-future
# plugin deps
# py3-pillow
RUN apk add --no-cache py3-magic
RUN apk add --no-cache py3-feedparser
RUN apk add --no-cache py3-dateutil
RUN apk add --no-cache py3-lxml
RUN apk add --no-cache py3-semver
# RUN apk add --no-cache py3-pillow --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
# TODO remove pillow, magic, feedparser, lxml, gitlab and semver when maubot supports installing dependencies

COPY requirements.txt /opt/maubot/requirements.txt
COPY optional-requirements.txt /opt/maubot/optional-requirements.txt
WORKDIR /opt/maubot

RUN apk add --virtual .build-deps python3-dev build-base git \
    && pip3 install -r requirements.txt -r optional-requirements.txt \
        dateparser langdetect python-gitlab pyquery tzlocal \
    && git clone -b sync-presence https://github.com/realtyem/mautrix-python.git ./mautrix-python \
    && pip3 install -e ./mautrix-python \
    && apk del .build-deps
# TODO also remove dateparser, langdetect and pyquery when maubot supports installing dependencies

COPY . /opt/maubot
RUN cp maubot/example-config.yaml .
COPY ./docker/mbc.sh /usr/local/bin/mbc
COPY --from=frontend-builder /frontend/build /opt/maubot/frontend
ENV UID=1337 GID=1337 XDG_CONFIG_HOME=/data
VOLUME /data

CMD ["/opt/maubot/docker/run.sh"]
