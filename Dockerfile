FROM tomcat:alpine

RUN apk add --no-cache imagemagick
RUN apk add --no-cache xpdf
RUN apk add --no-cache freetype-dev

RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY ./tomcat-config/server.xml /usr/local/tomcat/conf/server.xml
COPY ./tomcat-config/OpenKM.xml /usr/local/tomcat/OpenKM.xml
COPY ./tomcat-config/OpenKM.cfg /usr/local/tomcat/OpenKM.cfg
COPY ./tomcat-config/jdbc-postgres.jar /usr/local/tomcat/lib/jdbc-postgres.jar
COPY ./target/OpenKM.war /usr/local/tomcat/webapps/OpenKM.war
