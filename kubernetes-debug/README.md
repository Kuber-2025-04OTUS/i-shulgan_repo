```shell
kubectl debug -it nginx-distroless --image=alpine --target=nginx --share-processes -- /bin/sh
```

```
Targeting container "nginx". If you don't see processes from this container it may be because the container runtime doesn't support this feature.
Defaulting debug container name to debugger-vcmrq.
If you don't see a command prompt, try pressing enter.
/ # ls -lah /proc/1/root/etc/nginx/
total 48K    
drwxr-xr-x    3 root     root        4.0K Oct  5  2020 .
drwxr-xr-x    1 root     root        4.0K Jul  9 17:11 ..
drwxr-xr-x    2 root     root        4.0K Oct  5  2020 conf.d
-rw-r--r--    1 root     root        1007 Apr 21  2020 fastcgi_params
-rw-r--r--    1 root     root        2.8K Apr 21  2020 koi-utf
-rw-r--r--    1 root     root        2.2K Apr 21  2020 koi-win
-rw-r--r--    1 root     root        5.1K Apr 21  2020 mime.types
lrwxrwxrwx    1 root     root          22 Apr 21  2020 modules -> /usr/lib/nginx/modules
-rw-r--r--    1 root     root         643 Apr 21  2020 nginx.conf
-rw-r--r--    1 root     root         636 Apr 21  2020 scgi_params
-rw-r--r--    1 root     root         664 Apr 21  2020 uwsgi_params
-rw-r--r--    1 root     root        3.5K Apr 21  2020 win-utf
```

```
/ # apk add tcpdump
fetch https://dl-cdn.alpinelinux.org/alpine/v3.22/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.22/community/x86_64/APKINDEX.tar.gz
(1/2) Installing libpcap (1.10.5-r1)
(2/2) Installing tcpdump (4.99.5-r1)
Executing busybox-1.37.0-r18.trigger
OK: 8 MiB in 18 packages
/ # tcpdump -nn -i any -e port 80
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
17:58:27.344138 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.39620 > 127.0.0.1.80: Flags [S], seq 2667156795, win 43690, options [mss 65495,sackOK,TS val 205222632 ecr 0,nop,wscale 9], length 0
17:58:27.344146 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.80 > 127.0.0.1.39620: Flags [S.], seq 1195482100, ack 2667156796, win 43690, options [mss 65495,sackOK,TS val 205222632 ecr 205222632,nop,wscale 9], length 0
17:58:27.344153 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.39620 > 127.0.0.1.80: Flags [.], ack 1, win 86, options [nop,nop,TS val 205222632 ecr 205222632], length 0
17:58:27.491153 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.39634 > 127.0.0.1.80: Flags [S], seq 1008510522, win 43690, options [mss 65495,sackOK,TS val 205222779 ecr 0,nop,wscale 9], length 0
17:58:27.491163 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 80: 127.0.0.1.80 > 127.0.0.1.39634: Flags [S.], seq 1005545285, ack 1008510523, win 43690, options [mss 65495,sackOK,TS val 205222779 ecr 205222779,nop,wscale 9], length 0
17:58:27.491171 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.39634 > 127.0.0.1.80: Flags [.], ack 1, win 86, options [nop,nop,TS val 205222779 ecr 205222779], length 0
17:58:27.551156 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 1234: 127.0.0.1.39634 > 127.0.0.1.80: Flags [P.], seq 1:1163, ack 1, win 86, options [nop,nop,TS val 205222839 ecr 205222779], length 1162: HTTP: GET / HTTP/1.1
17:58:27.551176 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.80 > 127.0.0.1.39634: Flags [.], ack 1163, win 84, options [nop,nop,TS val 205222839 ecr 205222839], length 0
17:58:27.551304 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 310: 127.0.0.1.80 > 127.0.0.1.39634: Flags [P.], seq 1:239, ack 1163, win 86, options [nop,nop,TS val 205222839 ecr 205222839], length 238: HTTP: HTTP/1.1 200 OK
17:58:27.551329 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.39634 > 127.0.0.1.80: Flags [.], ack 239, win 86, options [nop,nop,TS val 205222839 ecr 205222839], length 0
17:58:27.551347 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 684: 127.0.0.1.80 > 127.0.0.1.39634: Flags [P.], seq 239:851, ack 1163, win 86, options [nop,nop,TS val 205222839 ecr 205222839], length 612: HTTP
17:58:27.551350 lo    In  ifindex 1 00:00:00:00:00:00 ethertype IPv4 (0x0800), length 72: 127.0.0.1.39634 > 127.0.0.1.80: Flags [.], ack 851, win 85, options [nop,nop,TS val 205222839 ecr 205222839], length 0
```

---

```shell
kubectl debug node/dev-hetzner-k8s-worker-2 -it --image=busybox
```

```
Creating debugging pod node-debugger-dev-hetzner-k8s-worker-2-tj69x with container debugger on node dev-hetzner-k8s-worker-2.
If you don't see a command prompt, try pressing enter.
/ # tail /host/var/log/pods/default_nginx-distroless_ae262faf-bafd-4dfa-8f53-9eb109e21c0d/nginx/0.log
2025-07-09T17:11:26.378547767Z stderr F 2025/07/10 01:11:26 [error] 7#7: *2 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 127.0.0.1, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "localhost:56871", referrer: "http://localhost:56871/"
2025-07-09T17:11:26.378578536Z stdout F 127.0.0.1 - - [10/Jul/2025:01:11:26 +0800] "GET /favicon.ico HTTP/1.1" 404 153 "http://localhost:56871/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15" "-"
2025-07-09T17:11:27.990177713Z stdout F 127.0.0.1 - - [10/Jul/2025:01:11:27 +0800] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15" "-"
2025-07-09T17:11:29.092326257Z stdout F 127.0.0.1 - - [10/Jul/2025:01:11:29 +0800] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15" "-"
2025-07-09T17:54:53.263425981Z stdout F 127.0.0.1 - - [10/Jul/2025:01:54:53 +0800] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15" "-"
2025-07-09T17:54:53.69662581Z stdout F 127.0.0.1 - - [10/Jul/2025:01:54:53 +0800] "GET /favicon.ico HTTP/1.1" 404 153 "http://localhost:56262/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15" "-"
2025-07-09T17:54:53.696634136Z stderr F 2025/07/10 01:54:53 [error] 7#7: *4 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 127.0.0.1, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "localhost:56262", referrer: "http://localhost:56262/"
2025-07-09T17:58:27.551463156Z stdout F 127.0.0.1 - - [10/Jul/2025:01:58:27 +0800] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15" "-"
2025-07-09T17:58:27.641330979Z stderr F 2025/07/10 01:58:27 [error] 7#7: *6 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 127.0.0.1, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "localhost:57227", referrer: "http://localhost:57227/"
2025-07-09T17:58:27.64135325Z stdout F 127.0.0.1 - - [10/Jul/2025:01:58:27 +0800] "GET /favicon.ico HTTP/1.1" 404 153 "http://localhost:57227/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15" "-"
```

---

```shell
kubectl debug -it nginx-distroless --image=alpine --target=nginx --share-processes -- /bin/sh
```

```
/ # apk add strace
/ # strace -p 1
strace: Process 1 attached
rt_sigsuspend([], 8
```
