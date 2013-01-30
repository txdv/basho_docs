Array.prototype.remove = (from, to)->
  rest = @slice((to || from) + 1 || @length)
  @length = if from < 0 then @length + from else from
  @push.apply(@, rest)

class ConsoleInstall

  constructor: (os)->
    @os = os

  read: (command)=>
    opts = @output[@os]
    ary = opts[command]
    unless ary
      ary = @output["default"][command]
    unless ary
      if command.match(/\s/)
        ary = [["Hey, let's install a database instead, shall we?"]]
      else
        ary = [["-bash: #{command}: command not found"]]
    for item, i in ary
      if item == "timer"
        ary.remove(i)
        @timer(ary, i)
    ary

  timer: (ary, pos)=>
    ary.splice(pos, 0, [" 100.0%", 1])
    for i in [0..50]
      ary.splice(pos, 0, ["#", 0.025, false])

  output:
    default: 
      "ls": [
        ["home      opt     tmp     dev     usr     bin     etc     net     root     sbin    var"]
      ]
      "pwd": [
        ["/"]
      ]
    debian:
      "sudo apt-get install riak": [
        ["Reading package lists.", 1, false]
        [".", 1, false]
        [".", 1, false]
        [" Done"]
        ["Building dependency tree", 1]
        ["Reading state information.", 1, false]
        [".", 1, false]
        [".", 1, false]
        [" Done"]
        ["The following NEW packages will be installed:"]
        ["  riak"]
        ["0 upgraded, 1 newly installed, 0 to remove and 3 not upgraded."]
        ["Need to get 25.3 MB of archives."]
        ["After this operation, 38.8 MB of additional disk space will be used."]
        ["Get:1 http://apt.basho.com/ precise/main riak amd64 1.2.1-1 [25.3 MB]", 2]
        ["Fetched 25.3 MB in 16s (1,533 kB/s)"]
        ["Selecting previously unselected package riak."]
        ["(Reading database ... 52122 files and directories currently installed.)"]
        ["Unpacking riak (from .../riak_1.2.1-1_amd64.deb) ...", 1]
        ["Processing triggers for ureadahead ...", 1]
        ["ureadahead will be reprofiled on next reboot"]
        ["Processing triggers for man-db ...", 1]
        ["Setting up riak (1.2.1-1) ...", 1]
        ["Adding group `riak' (GID 115) ...", 1]
        ["Done."]
        ["Adding system user `riak' (UID 108) ...", 1]
        ["Adding new user `riak' (UID 108) with group `riak' ...", 1]
        {complete: "You just installed Riak!"}
      ]
      "apt-get install riak": [
        ["Please prefix with sudo"]
      ]
    freebsd:
      "sudo pkg_add -r http://downloads.basho.com.s3-website-us-east-1.amazonaws.com/riak/1.2/1.2.1/freebsd/9/riak-1.2.1-FreeBSD-amd64.tbz": [
        {complete: "You just installed Riak!"}
      ]
    osx: 
      "brew install riak": [
        ["==> Downloading http://downloads.basho.com.s3-website-us-east-1.amazonaws.com/riak/1.2", 1]
        "timer"
        ["Warning: skip_clean :all is deprecated"]
        ["Skip clean was commonly used to prevent brew from stripping binaries."]
        ["brew no longer strips binaries, if skip_clean is required to prevent"]
        ["brew from removing empty directories, you should specify exact paths"]
        ["in the formula."]
        ["/usr/local/Cellar/riak/1.2.1-x86_64: 1834 files, 43M, built in 24 seconds"]
        {complete: "You just installed Riak!"}
      ]
      "sudo brew install riak": [
        ["Error: Cowardly refusing to `sudo brew install'"]
      ]
    rhel:
      "sudo yum install riak": [
        ["Installing"]
        {complete: "You just installed Riak!"}
      ]
      "yum install riak": [
        ["Please prefix with sudo"]
      ]

window.ConsoleInstall = ConsoleInstall
