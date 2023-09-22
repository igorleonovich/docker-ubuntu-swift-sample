# Docker Ubuntu Swift Sample

Ubuntu container for Swift (Sample) (Docker)

It's useful for build & run Swift applications from Docker container via ssh remotely

### Run
- Run `./configure.sh` (or generate ssh key into `key` folder manually)
- Update `.env` with own values

### Usage
- Run `ssh -p 2222 -i ./key/key root@localhost 'swift-sample'`

### Todo
- SSH access to `ubuntu` user (now `root` is working only)
