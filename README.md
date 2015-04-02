Bogo's input plugins for common toolkits.  Only Gtk+ 2 is supported at
the moment.

## How to test

Make sure you have the latest Vala compiler and development headers
for Gtk+ 2 installed.

```bash
$ make

# Update Gtk's immodules cache at
# /usr/lib/gtk-2.0/<version>/immodules.cache to include bogo.
# It's a plaintext file, open and see for yourself.
$ sudo GTK_PATH=$PWD gtk-query-immodules-2.0 --update-cache

# Run a Gtk 2 app with bogo. Candidates
# include: pluma, terminator, firefox, chromium, etc.
$ GTK_IM_MODULE=bogo G_MESSAGES_DEBUG=all terminator
```

Now press a random key.  You should see 'aaaa'. Then press **a**, the
4 a's should change to 'bbbb'.

To uninstall, update Gtk's cache again but without `GTK_PATH` set.

```bash
$ sudo gtk-query-immodules-2.0 --update-cache
```
