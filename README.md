# Shibboleth IDP

## Building

Depending on your religious beliefs, you may favor the Oracle JDK or the
OpenJDK version, so in a gesture toward pan-ecclesiastical harmony, there
are docker scripts for both OpenJDK and ther Oracle JDK. 

Make a copy of your favorite and name it Dockerfile, then run the build
script:

```
cp Dockerfile.OpenJDK Dockerfile
./build
```

NOTE: Oracle wants you to agree to their license terms here for the
JDK and the Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files 8 
found on these two pages:
```
http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html
```
so go do that before you even **_think_** of building the OracleSDK version.

### How to verify the IDP from inside the container

0.) run an instance

```
   ./run
```
  
1.) find the id for the docker instance
```
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS                                               NAMES
c6bb80bf3ce2        shibboleth-idp      "/usr/sbin/init"    About a minute ago   Up About a minute   80/tcp, 443/tcp, 8443/tcp, 0.0.0.0:8080->8080/tcp   tiny_ramanujan
```
   
2.) use the docker exec command to start a bash shell and then use curl to ask for status:
```
$ sudo docker exec -it c6bb80bf3ce2 bash
[root@c6bb80bf3ce2 /]# curl http://localhost:8080/idp/status
### Operating Environment Information
operating_system: Linux
operating_system_version: 3.13.0-85-generic
operating_system_architecture: amd64
jdk_version: 1.8.0_77
available_cores: 4
used_memory: 1056 MB
maximum_memory: 3566 MB

### Identity Provider Information
idp_version: 3.2.1
start_time: 2016-04-07T21:54:16Z
current_time: 2016-04-07T21:55:21Z
uptime: 64967 ms

service: shibboleth.LoggingService
last successful reload attempt: 2016-04-07T21:53:57Z
last reload attempt: 2016-04-07T21:53:57Z

service: shibboleth.ReloadableAccessControlService
last successful reload attempt: 2016-04-07T21:53:59Z
last reload attempt: 2016-04-07T21:53:59Z

service: shibboleth.MetadataResolverService
last successful reload attempt: 2016-04-07T21:53:59Z
last reload attempt: 2016-04-07T21:53:59Z

	metadata source: ShibbolethMetadata

service: shibboleth.RelyingPartyResolverService
last successful reload attempt: 2016-04-07T21:53:58Z
last reload attempt: 2016-04-07T21:53:58Z

service: shibboleth.NameIdentifierGenerationService
last successful reload attempt: 2016-04-07T21:53:58Z
last reload attempt: 2016-04-07T21:53:58Z

service: shibboleth.AttributeResolverService
last successful reload attempt: 2016-04-07T21:53:58Z
last reload attempt: 2016-04-07T21:53:58Z

	DataConnector staticAttributes: has never failed

service: shibboleth.AttributeFilterService
last successful reload attempt: 2016-04-07T21:53:58Z
last reload attempt: 2016-04-07T21:53:58Z

[root@c6bb80bf3ce2 /]# 

```
