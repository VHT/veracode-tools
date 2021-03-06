FROM openjdk:11

RUN apt-get update \
&& apt-get install -y apt-transport-https make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git zip jq \
&& rm -rf /var/lib/apt/lists/*

# Install NodeJS and Yarn
RUN groupadd --gid 1000 node   && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
ENV NODE_VERSION=12.17.0
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)"     && case "${dpkgArch##*-}" in       amd64) ARCH='x64';;       ppc64el) ARCH='ppc64le';;       s390x) ARCH='s390x';;       arm64) ARCH='arm64';;       armhf) ARCH='armv7l';;       i386) ARCH='x86';;       *) echo "unsupported architecture"; exit 1 ;;     esac     && set -ex     && apt-get update && apt-get install -y ca-certificates curl wget gnupg dirmngr xz-utils libatomic1 --no-install-recommends     && rm -rf /var/lib/apt/lists/*     && for key in       94AE36675C464D64BAFA68DD7434390BDBE9B9C5       FD3A5288F042B6850C66B31F09FE44734EB7990E       71DCFD284A79C3B38668286BC97EC7A07EDE3FC1       DD8F2338BAE7501E3DD5AC78C273792F7D83545D       C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8       B9AE9905FFD7803F25714661B63B535A4C206CA9       77984A986EBC2AA786BC0F66B01FBB92821C587A       8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600       4ED778F539E3634C779C87C6D7062848A1AB005C       A48C2BEE680E841632CD4E44F07496B3EB3C1762       B9E2F5981AA6E0CD28160D9FF13993A75599653C     ; do       gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ||       gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" ||       gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ;     done     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz"     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"     && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc     && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c -     && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner     && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt     && apt-mark auto '.*' > /dev/null     && find /usr/local -type f -executable -exec ldd '{}' ';'       | awk '/=>/ { print $(NF-1) }'       | sort -u       | xargs -r dpkg-query --search       | cut -d: -f1       | sort -u       | xargs -r apt-mark manual     && ln -s /usr/local/bin/node /usr/local/bin/nodejs     && node --version     && npm --version
ENV YARN_VERSION=1.22.4
RUN set -ex   && savedAptMark="$(apt-mark showmanual)"   && apt-get update && apt-get install -y ca-certificates curl wget gnupg dirmngr --no-install-recommends   && rm -rf /var/lib/apt/lists/*   && for key in     6A010C5166006599AA17F08146C2130DFD2497F5   ; do     gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ||     gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" ||     gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ;   done   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz"   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc"   && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz   && mkdir -p /opt   && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg   && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz   && apt-mark auto '.*' > /dev/null   && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; }   && find /usr/local -type f -executable -exec ldd '{}' ';'     | awk '/=>/ { print $(NF-1) }'     | sort -u     | xargs -r dpkg-query --search     | cut -d: -f1     | sort -u     | xargs -r apt-mark manual   && yarn --version

ENV PATH="/root/.pyenv/bin:/root/.pyenv/shims/:${PATH}"
RUN curl -s https://pyenv.run | bash \
&& echo 'eval "$(pyenv init -)"\neval "$(pyenv virtualenv-init -)"' > /root/.bashrc \
&& . /root/.bashrc \
&& PYENV_LATEST_V2=$(pyenv install --list | sed 's/^  //' | grep -P '^2.7.\d' | grep -v 'dev\|a\|b' | tail -1) \
&& PYENV_LATEST=$(pyenv install --list | sed 's/^  //' | grep -P '^\d' | grep -v 'dev\|a\|b' | tail -1) \
&& pyenv install $PYENV_LATEST_V2 \
&& pyenv install $PYENV_LATEST \
&& pyenv global $PYENV_LATEST_V2 \
&& pip install --upgrade pip \
&& pip install 'httpie>=0.9.9,<2' \
&& pip install veracode-api-signing

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DF7DD7A50B746DD4 \
&& echo 'deb https://download.sourceclear.com/ubuntu stable/' > /etc/apt/sources.list.d/srcclr.list \
&& apt-get update \
&& apt-get install srcclr

#====================#
## Ruby Setup
#====================#
USER root
RUN apt-get install -y libssl-dev libreadline-dev zlib1g-dev nodejs
RUN wget https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.gz
RUN tar -zxvf ./ruby-2.6.5.tar.gz

WORKDIR ./ruby-2.6.5
RUN ./configure && make && make install
RUN gem install --no-document bundler

# https://stackoverflow.com/questions/47026174/find-spec-for-exe-cant-find-gem-bundler-0-a-gemgemnotfoundexception/54083113#54083113
RUN gem update --system

WORKDIR /veracode

RUN VERACODE_WRAPPER_VERSION=$(curl -sS "https://search.maven.org/solrsearch/select?q=g:%22com.veracode.vosp.api.wrappers%22&rows=20&wt=json" | jq -r '.["response"]["docs"][0].latestVersion') \
&& curl -sS -o veracode-wrapper.jar "https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/${VERACODE_WRAPPER_VERSION}/vosp-api-wrappers-java-${VERACODE_WRAPPER_VERSION}.jar" \
&& echo "Veracode wrapper version $VERACODE_WRAPPER_VERSION"

RUN curl -sS -O https://downloads.veracode.com/securityscan/gl-scanner-java-LATEST.zip \
&& unzip gl-scanner-java-LATEST.zip gl-scanner-java.jar && rm -f gl-scanner-java-LATEST.zip

RUN curl -sS -O https://downloads.veracode.com/securityscan/pipeline-scan-LATEST.zip \
&& unzip pipeline-scan-LATEST.zip pipeline-scan.jar && rm -f unzip pipeline-scan-LATEST.zip

# Install tar-globs
RUN yarn global add @vht/tar-globs

# Copy in utility scripts
COPY ./bin/veracodeupload.sh /usr/local/bin/

# Build vht-veracode.jar utility
WORKDIR /veracode/vht-veracode
COPY ./vht-veracode .
RUN ./build.sh
RUN cp *.jar /veracode

WORKDIR /workspace
