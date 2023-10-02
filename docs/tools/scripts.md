# Scripts

Nettux comes with a few helpful scripts to make a few tasks a bit easier.

## nshost Scripts

The `nshost-*` scripts help you quickly make network namespace "hosts" and connect them.

- `nshost-create <NAME>`: Creates a network namespace "host" with the given `<NAME>`. Note the name must be less than 5 characters long. This allows the name to be put in the interface name easily.
- `nshost-list`: Lists all network namespace "hosts."
- `nshost-conn <HOST1> <HOST2>`: Connects two network namespace "hosts" together. Creates the interfaces `<HOST1>-<HOST2>-#` on `<HOST1>` and the reverse (`<HOST2>-<HOST1>-#`) on `<HOST2>`. This makes it easy to see what interface connects to what neighbor.
- `nshost-shell <NAME>`: Opens a bash shell in the network namespace. The prompt is prepended with the name of the "host."
- `nshost-del <NAME>`: Deletes the network namespace "host." Note it doesn't stop processes operating in that namespace.
- `nshost-ext-conn <HOST>`: Creates a connection from the namespace "host" to the main namespace. This serves as an external connection to `<HOST>`. Creates the interfaces `<HOST>-ext-#` in `<HOST>` and the reverse (`ext-<HOST>-#`) on the main namespace.

## router Scripts

The `router-*` scripts help create and remove FRRouting processes up and down to create virtual routers.

!!! warning

    Be sure to be in the network namespace you want the virtual router to operate in, otherwise services will overlap, probably not start at all, and not be in the correct namespace.

!!! note

    If a network namespace is destroyed, the processes attached to it will not be stopped or switched. Remember to stop and start virtual routers when starting and stopping the Mininet simulations, since network namespaces are destroyed.

- `router-init <ROUTER_NAME>`: Initializes the configuration files for a virtual router named `<ROUTER_NAME>`. Its recommended to name it after the namespace or Mininet hostname.
- `router-start <ROUTER_NAME>`: Starts all router processes for the virtual router named `<ROUTER_NAME>`. Only run this in the network namespace/Mininet "host" you want this router to run. `router-init` must be run before starting the router with this script. 
- `router-shell <ROUTER_NAME>`: Opens a `vtysh` shell for the FRRouting processes to configure the virtual router `<ROUTER_NAME>`. The router must be started.
- `router-stop <ROUTER_NAME>`: Stops all router processes for the virtual router named `<ROUTER_NAME>`.
- `router-destroy <ROUTER_NAME>`: Stops and removes all configuration files for the virtual router named `<ROUTER_NAME>`.
