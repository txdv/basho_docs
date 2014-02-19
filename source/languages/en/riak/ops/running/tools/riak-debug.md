---
title: riak-debug Command Line
project: riak
version: 1.2.0+
document: reference
toc: true
audience: intermediate
keywords: [command-link, riak-debug]
---

This command creates a tarball in the `/bin` directory of a Riak node containing a variety of log, configuration, and other files displaying granular information about the status and history of the node. It is suggested that you use this command only if you have filed a ticket with Basho's Client Services team.

The command is always used by itself and has no sub-commands:

```bash
riak-debug
```

Once the debug process is initiated, you'll see output in the console along the following lines:

```bash
......E....E....E...EE...E..
```

This is completely normal, and signifies only that the tarball is being created. Once the process is finished, the resulting `.tar.gz` file will be placed in the node's `/bin` directory. You can then examine the contents of the tarball yourself or pass it along to Basho's Client Services team during to assist in the debugging process.

You may receive the following error while executing `riak-debug`:

```bash
Temporary directory already exists. Aborting.
<path_to_temp_dir>
```

This error arises when `riak-debug` was run previously and prematurely aborted. If you receive this error, simply delete the temporary directory located at `<path_to_temp_dir>` in the console output and run `riak-debug` again.