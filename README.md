# opensips-count-ext-api
This is simple Flask API to check how many times Requester send request to the extension (phone number)<br>
When getting request from Requesters to `$rU`, the API will check `$rU` from `acc` table in opensips database,if `sip_code` in `[200,408,486,487,600]` it will be counted at one and Requester just have max 5 connection to the extension.<br>
You can modify condition as you wish on [pyapp/app.py](https://github.com/mach1el/opensips-count-ext-api/pyapp/app.py) at line `46`.<br>
Due it will check data from database,hence you must define your database servers in [pyapp/servers](https://github.com/mach1el/opensips-count-ext-api/pyapp/servers)


## requirement
```
pip install -r requirements.txt
```

## Using docker image
* **Build**
```
docker build --rm -t opensips-api:count-extension .
```

* **Run**
```
docker run -tid --rm --name=api -p5000:2000 opensips-api:count-extension
```

## Run request
```
curl -ik http://10.10.10.10:2000/check\?from\=worker1\&extension\=0123456789
```

## Opensips configuration
```
...
loadmodule "rest_client.so"
modparam("rest_client", "curl_timeout", 10)
modparam("rest_client", "connection_timeout", 5)
modparam("rest_client", "max_async_transfers", 300)
modparam("rest_client", "ssl_verifypeer", 0)
modparam("rest_client", "ssl_verifyhost", 0)
...

route {
...
$var(request) = rest_get("http://10.10.94.129:2000/check?from=worker1&extension=$rU",
                  $var(data),$var(ct),$var(rcode));
$json(data) := $var(data);
$var(status) = $json(data[0]/status);
if ($var(rcode) == 504) {
  xlog("----- [BLACKLIST CHECK][$var(status)]: $rU is temporary blacklisted\n");
  acc_db_request("Temporary Blacklisted", "acc");
  sl_send_reply(504, "Temporary Blacklisted");
  exit;
  }
...
}
```