# redis-snap

This is an out-of-tree snap for Redis, the popular data store.

## Building

With Ubuntu 16.04 and snapcraft installed:

```
git clone https://github.com/markshuttle/redis-snap
cd redis-snap
snapcraft
```

The snap will be built as redis_3.2.3+git_amd64.snap.

Unless you have setup snapcraft signing keys, install with
`sudo snap install --force-dangerous <name>.snap` which bypasses snapd's
preference for signed snaps. This snap will in due course be available
signed from the store as `snap install redis`.

