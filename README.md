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

An official stable build of this snap will in due course be available from
the store as `snap install redis`.

## Once installed

Redis will try to start on boot, looking for configuration files in
/var/snap/redis/common/\*.conf and starting the databases described in
those.

A default config can be installed with `sudo redis.init`. Once the
system is running you can manage the daemon with
`sudo service snap.redis.launch start|stop|status`.

