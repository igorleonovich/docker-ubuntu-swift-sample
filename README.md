# Docker Ubuntu Swift Sample

Build & run Swift applications from Docker container via ssh

### Run
- Run `./configure.sh` (or generate ssh key into `key` folder manually)
- Update `.env` with own values
- Run `./up.sh` 

### Usage
- Run `ssh -p 2222 -i ./key/key root@localhost 'swift-sample'`

### Todo
- SSH access to `ubuntu` user (now `root` is working only)
  - https://superuser.com/questions/1514272/global-ssh-key-working-for-root-user-but-not-for-other-users

### Notes
- For clean Docker stopped resources and up again, run `reup.sh`
