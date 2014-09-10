FORMAT: 1A
HOST: http://test_riak_cluster:8098

# Riak HTTP API
Riak has an HTTP API that you can use to access of all its provided functionality, from basic
key/value operations to Riak Search queries to Riak Data Type operations and more.

# Group Basic Cluster Operations
## Ping [/ping]
### Ping the targeted Riak node [GET]
+ Response 200 (text/plain)
    + Headers
    
            Server: MochiWeb/1.1 WebMachine/1.10.5 (jokes are better explained)

    + Body
    
            OK

+ Response 404 (text/plain)

## Bucket type properties [/types/{bucket_type}/props]
### Get default bucket properties [GET]