Set ENV values from consul KV lookups

Check out if [envconsul](https://github.com/hashicorp/envconsul) solves your needs before trying this.

 - Uses [Consul transactions api](https://www.consul.io/api/txn.html) to only do a single request for all keys.
 - Fails if consul returns any errors
 - Returns not found as `nil`
 - Connects to `CONSUL_HTTP_ADDR` ENV var or `localhost:8500`
 - TODO: support `CONSUL_HTTP_SSL`

Install
=======

Not released to rubygems since this is just a proof of concept atm ... to use it clone the repo or download lib/enconsul.rb

Let me know if you want to use it and I can release it to rubygems.

Usage
=====

```Ruby
Consulenv.load(
  "some/key" => "ENV_KEY_TO_USE",
  "other/key" => "FOOBAR",
)
```

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/consulenv.png)](https://travis-ci.org/grosser/consulenv)
