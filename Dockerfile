FROM redash/redash:preview
LABEL maintainer="Godwin peter .O <me@godwin.dev>"
USER root
RUN cd /tmp \
    # Start oracle installation
    && mkdir -p /tmp/oracle && cd /tmp/oracle \
    && curl -L https://raw.github.com/gpproton/php7-with-oci8/master/instantclient/19.3.0.0.0/instantclient-basiclite-linux.x64-19.3.0.0.0dbru.zip -O \
    && curl -L https://raw.github.com/gpproton/php7-with-oci8/master/instantclient/19.3.0.0.0/instantclient-sdk-linux.x64-19.3.0.0.0dbru.zip -O \
    && curl -L https://raw.github.com/gpproton/php7-with-oci8/master/instantclient/19.3.0.0.0/instantclient-sqlplus-linux.x64-19.3.0.0.0dbru.zip -O \
    && unzip '*.zip' -d /usr/local/ \
    && ln -s /usr/local/instantclient_19_3 /usr/local/instantclient \
    && ln -s /usr/local/instantclient/lib* /usr/lib \
    && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \
    && echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc \
    && echo 'umask 002' >> /root/.bashrc \
    && cd /tmp/ && rm -rf /tmp/oracle \
    # End oracle installation
    # Start sql server requirement here.
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update && ACCEPT_EULA=Y apt-get install -yq msodbcsql17 mssql-tools \
    && apt-get install -yq locales unixodbc-dev libaio-dev \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

ENV ORACLE_HOME=/usr/local/instantclient
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/instantclient
ENV PATH=/usr/local/instantclient:$PATH
RUN pip install cx_Oracle
USER redash

#Add REDASH ENV to add Oracle Query Runner 
ENV REDASH_ADDITIONAL_QUERY_RUNNERS=redash.query_runner.oracle
