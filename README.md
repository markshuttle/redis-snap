# redis-snap

This is snap for Redis, the popular data store.

## Building

With Ubuntu 16.04 and snapcraft:

```
git clone https://github.com/markshuttle/redis-snap
cd redis-snap
snapcraft
```

The snap will be redis_version+git_amd64.snap in that directory.

Unless you have setup snapcraft signing keys, install with
`sudo snap install --force-dangerous <name>.snap` which bypasses
the requirement for a signature.

This snap will in due course be available signed from the store as
`snap install redis`.

## Once installed

Redis will try to start on boot, looking for a configuration in
/var/snap/redis/common/redis.conf which can be created after installation
with `sudo redis.launch init`. Once the system is running you can start or
stop the daemon with `sudo redis.launch start|stop`.
