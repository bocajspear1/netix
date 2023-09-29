# 3. Simple Routing

"Routing" is how a computer determines where network traffic should go. Each system has a routing table, which determines where to send things. On Linux, you can view the routing table with `ip route`. Here's an example routing table from the `l` namespace:

``` bash
(l) root@nettux:/home/nettux# ip route
192.168.70.0/24 dev l-c-0 proto kernel scope link src 192.168.70.2 
```

`l` uses this table to direct its connections. Anything not on this table will be dropped and go nowhere. If you are lucky, you'll get an error, but sometimes you will not. If you are having connection issues, always check the routing table!

Note that the routing table for `l` is pretty empty. It knows how to route to the network directly connected to it, but nothing else. As seen before, if we try to connect to anything outside the directly connected network, such as `r`, we get an error (we're lucky this time!). We need to fix this so we can connect to `r`.

## Default Routes

A "default route" is essentially passing your problem to another system. The default route is used when no other route in the routing table matches the destination of your network traffic. This passing-of-duty is very practical, as otherwise your computer would have to know how to route to everything on the internet! By passing this responsibility along, we can hand over the routing to another system, usually a router (hence the name), which communicates with other routers to determine where to put your traffic.

Even most routers don't know how to route to everything on the internet, and pass it along to somebody they think will hopefully know. Otherwise, the router simply drops it. The traffic is gone, and if you are very lucky, you get an ICMP packet with and error. Most of the time though, it simply disappears, never to be seen again.

Note that each router asks the same question: "how do I get there?" Each router too has a routing table which is its guide to answering this question. If it can't the traffic is dropped and disappears. Keep this in mind going forward.

## Setting a Default Route

To set a default route in Linux, use the following command:

``` shell
ip route add default via <IP>
```

The `<IP>` should be the system you want to pass traffic to, the one you hope will know how to send it towards the destination.

In the case of `l`, that is `c`, so lets set the default route on `l` to the IP on `c`.

> Make sure the default route is set to an IP on your connected network, otherwise things will get messed up!

``` bash
(l) root@nettux:/home/nettux# ip route add default via 192.168.70.1
```

> Note: You don't need to set the prefix/netmask here

If we run `ip route` again, notice we have a new entry indicating our default route:

``` bash
(l) root@nettux:/home/nettux# ip route
default via 192.168.70.2 dev l-c-0 
192.168.70.0/24 dev l-c-0 proto kernel scope link src 192.168.70.2 
```

## Testing Again

Lets try pinging `r` again:

``` bash
(l) root@nettux:/home/nettux# ping 172.17.40.2
PING 172.17.40.2 (172.17.40.2) 56(84) bytes of data.
^C
--- 172.17.40.2 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1009ms
```

And it hangs, we get no responses (Use ctrl-c to stop it). That's progress, but we want a response.

Remember our question: "How do I get there?" `c` knows, since its connected to both networks. However, `r` currently only knows about `c` and the network that connects those two, but now about how to **get back** to `l`.

``` bash
  ---->   ---->
l       c       r
               ??<-
```

Networking is a two-way street, you have to know how to get there and how to get back. `r` doesn't know how to get back, so its dropping the traffic, hence the hang without any error. It can't send an error back to `l` since it can't get there in the first place! Before you set a default gateway on `r`, lets look at another method of telling the routing table how to get there.

## Static Routes

!!! warning

     Did you set a default route on `r`? You shouldn't have... delete it with `ip route del default`

Static routes are essentially you inserting a direct into the routing table. You need to know how to get from point A to point B ahead of time, and you tell the computer how to do it.

Static routes are similarly set in Linux to default routes, but instead we replace `default` with the network address we're trying to get to.

``` bash
ip route add <NETWORK_IP> via <IP_NEXT_HOP>
```

!!! Note

     The term "next hop" is usually used to refer to who the routing table sends data of a certain destination.

If you need to delete a route (for example, if you mis-typed something), use this command:

``` bash
ip route del <NETWORK_IP> via <IP_NEXT_HOP>
```

So on `r`, we can insert into `r`'s routing table that to get to `l`'s network (`192.168.40.0/24`), we send it to `c`:

``` bash
(r) root@nettux:/home/nettux# ip route add 192.168.70.0/24 via 172.17.40.1
```

Note our new entry in `r`'s routing table:

``` bash
(r) root@nettux:/home/nettux# ip route
172.17.40.0/24 dev r-c-0 proto kernel scope link src 172.17.40.2 
192.168.70.0/24 via 172.17.40.1 dev r-c-0 
```

If we go back to `l` and ping again:

``` bash
(l) root@nettux:/home/nettux# ping 172.17.40.2
PING 172.17.40.2 (172.17.40.2) 56(84) bytes of data.
64 bytes from 172.17.40.2: icmp_seq=1 ttl=63 time=0.189 ms
64 bytes from 172.17.40.2: icmp_seq=2 ttl=63 time=0.090 ms
```

SUCCESS!!!!!! We've done it! Once you're done here, you can move on to [part 4](4-iptables.md).

## Troubleshooting

Having issues? Check this list out:

- Make sure the routing table matches the networks. Use `ip route` to verify the routing table. Remember that table is what is used to guide traffic!
