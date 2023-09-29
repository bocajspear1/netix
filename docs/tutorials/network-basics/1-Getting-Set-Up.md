# 1. Getting Set Up

> This is a slight rework of my tutorial here: [https://netbasics.j2h2.io/](https://netbasics.j2h2.io/)

## Assumptions

- You are familiar with basic networking concepts, like IP addresses, network masks, and simple subnetting.
- You have some familiarity with Linux and the Linux command line.

## Networking Mindset

One of the biggest problems to solve in networking is the question "how do I get there?" Sometimes questions "how fast do I get there?" or "how do I get there securely?" are asked, but the essential issue is getting their in the first place. If you can't get there at all, no other questions matter.

When setting up and configuring networks, always keep that in mind. By default, computers don't know how to get anywhere, and you need to tell them how to get from point A to point B, or tell them somebody else that knows how to get from point A to point B. When troubleshooting a networking issues, first ask if the computer you are on knows how to get to that destination or not. This mindset will be helpful in lab ahead and your day-to-day networking problems.

## Some Configuration

!!! note
    
    Nettux already does this, but I'll keep it here for reference

We need to allow Linux to route traffic. This is done with:

``` bash
$ sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
$
```

> Note: This only hold until the system reboots. You'll need to run this every time the system reboots.

To verify Linux routing is enabled, run the following:

``` bash
$ cat /proc/sys/net/ipv4/ip_forward
1
```

## Network Namespaces

The basis of this lab will using Linux network namespaces. Network namespaces are separate network stacks, essentially different sets of routing and address information. Linux usually uses these for things like containers, which allows them to network similar to a physical system. Here we use them to go over basics in networking and network troubleshooting, beyond just setting IP addresses.

## Our Topology

Using network namespaces, we'll create a simple network like this:

``` bash
l <---> c <---> r
```

## Creating Our Namespaces

Nettux has some scripts that will make creating and configuring our network namespaces easy. These are `nshost-create`, `nshost-list`, `nshost-conn`, and `nshost-shell`.

!!! warning

    These commands will not available off of Nettux. Use the [original tutorial](https://netbasics.j2h2.io/) if on another system.

We will need 3 namespaces, which we'll call `l` (left), `c` (center) and `r` (right). You will need root access to create namespaces, note the use of `sudo`. Use these commands:

``` bash
sudo nshost-create l
sudo nshost-create c
sudo nshost-create r
```

You can verify their creation with the `nshost-list` command:

``` bash
$ sudo nshost-list
r
c
l
```

Now we need to enter the namespaces. What I recommend is opening separate tabs in your terminal emulator (or separate tmux windows) for each namespace. Use the following command to run a `bash` shell in a namespace:

``` bash
sudo nshost-shell <NAMESPACE_NAME>
```

Note you have the namespace's name now prepended to your prompt. You are also root. Notice that if you run `ip addr` you have no interfaces in the namespace other that the loopback interface:

``` bash
# ip addr
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

Welcome to the namespace! 

## Connecting Our Namespaces

We will need to add virtual interfaces to connect them together. These interfaces will effectively work like real network adapters. If you are in a namespace shell, exit it with the `exit` command.

To connect your namespaces, enter the following commands **not in a namespace!**:

``` bash
sudo nshost-conn l c
sudo nshost-conn c r
```

If you run `ip addr` in your namespaces, you should now see more than one interface. Now you can move on to [part 2](./2-The-Very-Basics.md)!
