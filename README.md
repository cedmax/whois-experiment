# whois experiment

a whois interface in node relying on a ruby backend through redis' pub/sub channel.

##disclaimer

This is just a personal experiment, there isn't a proper documentation, the following things are just a way to remember how to run it on my webfaction server, sorry :)

### redis

```shell
~/redis/src/redis-server redis/redis.conf
~/redis/src/redis-cli -p 32733
> MONITOR
```

### ruby

```shell
cd ruby
export GEM_HOME=$PWD/gem
export PATH=$PWD/gem/bin:$PATH

gem1.9 install bundler
bundle install

irb1.9
> load "./whois.rb"
```

### node

```shell
cd node
node whois.js cedmax.com
```
