Bogo's input plugins for common toolkits.  Only Gtk+ is supported at
the moment.

## How to test

Make sure you have the latest Vala compiler and development headers
for Gtk+ 2, Gtk+ 3 and Python 3 installed.

```bash
# Install bogo-python.  Just make sure you're using Python 3.
$ sudo pip3 install bogo

$ make

# Run a Gtk+ 2 app with bogo.  Candidates
# include: pluma, terminator, firefox, chromium, etc.
$ make run GTK=2 CMD=pluma

# or Gtk+ 3:
$ make run GTK=3 CMD=gedit
```

Type some Vietnamese.  Only TELEX is supported ATM.

Uninstall:

```bash
$ sudo pip3 uninstall bogo
```
