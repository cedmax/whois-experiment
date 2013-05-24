/*global process, console, require */
(function(){
    "use strict";

    var db, redis = require('redis');

    var logData = function(data) {
        console.log(JSON.stringify(JSON.parse(data), null, 4));
    };

    function checkDataFormat(domain) {
        return  (/(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)/.test(domain));
    }

    function queryBackend(domain, redis){
        var pub = redis.createClient(32733);
        var sub = redis.createClient(32733);

        sub.on("connect", function(){
            sub.on("message", function(a, whois){
               db.set(domain, whois, function(){
                    db.expire(domain, 3600);
                    db.end();
                    sub.end();
                    pub.end();
                    process.exit(0);
               });
               logData(whois);
            });
            sub.subscribe("whois-result");
        });

        pub.on("connect", function() {
            pub.publish("whois", domain);
        });
    }

    function enstablishConnection(domain) {
        db.get(domain, function(err, whois){
            if (whois) {
                logData(whois);
                process.exit(0);
            } else {
                queryBackend(domain, redis);
            }
        });
    }

    var dmn = process.argv[2];
    if (checkDataFormat(dmn)) {
        db = redis.createClient(32733);
        enstablishConnection(dmn);
    } else {
        process.exit(1);
    }

})();

