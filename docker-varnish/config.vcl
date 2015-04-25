# backend configuration set from start.sh
backend default {
    .host = "%BACKEND_IP%";
    .port = "%BACKEND_PORT%";
}

sub vcl_recv {
    set req.backend = default;

    # check for a reload
    if (req.http.Cache-Control ~ "no-cache") {
         set req.hash_always_miss = true;
    }

    # don't cache /ghost/ admin pages    
    if (req.url ~ "^.*/ghost/.*$") {
        return (pass);
    } else {
        return(lookup);
    }
}

sub vcl_miss {    
    return(fetch);
}

sub vcl_hit {
    return(deliver);
}

sub vcl_fetch {
    # cache content for up to 9 hours
    set beresp.ttl = 9h;
    set beresp.http.X-Cacheable = "YES";
    unset beresp.http.Vary;
    return(deliver);
}

sub vcl_deliver {
    return(deliver);
}

sub vcl_error {
    # redirect if the backend is down
    if (req.url ~ "^/?$") {
        set obj.status = 302;
        set obj.http.Location = "https://giantswarm.io/";
    }
}
