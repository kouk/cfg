Server management utilities
===========================

`vmcons`
--------

A utility to setup ssh port forwarding, optionally based on a ssh config entry,
through a host with access to a virtual machine's console. Supports VNC as well
(standard VNC ports must be used).

Example of ssh config:

    Host *.vm
    User admin
    ExitOnForwardFailure yes

    Host my.vm
    LocalForward 1234 localhost:1234
    HostName vmhost


