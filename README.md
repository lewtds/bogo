Bogo's input plugins for common toolkits.  Only Gtk+ is supported at
the moment.

## How to test

Make sure you have the latest Vala compiler (0.24+, won't run with
0.22) and development headers for Gtk+ 2, Gtk+ 3 and Python 3
installed.

```bash
# Install bogo-python.  Just make sure you're using Python 3.
$ sudo pip3 install bogo

$ make

# Keep the server running in a separate terminal
$ ./build/server

# Run a Gtk+ 2 app with bogo.  Candidates include: pluma, terminator,
# firefox, chromium, etc.  Note that you HAVE to be clear about the
# Gtk version as loading Gtk 2's plugin in a Gtk 3 app will crash it.
$ make run GTK=2 CMD=pluma

# or Gtk+ 3:
$ make run GTK=3 CMD=gedit
```

Type some Vietnamese.  Only TELEX is supported ATM.  Check out the
[Testing](https://github.com/lewtds/bogo/wiki/Testing) page in the
wiki for more test cases.

Uninstall:

```bash
$ sudo pip3 uninstall bogo
```
