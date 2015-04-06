[DBus (name = "org.bogo.Server")]
public class Server : Object {
	StringBuilder builder;

	public Server() {
		builder = new StringBuilder();

		Python.initialize_ex(0);

		Python.run_simple_string("print('hello')");
	}

	~Server() {
		// FIXME: Code never reached
		Python.finalize();
	}

	public void process_key(uint keyval,
							Gdk.ModifierType modifiers,
							out uint chars_to_delete,
							out string commit_string,
							out bool swallowed) {
		debug("mods: %d val: %u", modifiers, keyval);
		if ((modifiers &
			 (Gdk.ModifierType.CONTROL_MASK)) != 0 ||
			keyval > 127) {
			chars_to_delete = 0;
			commit_string = "";
			swallowed = false;
			debug("skipped");
			builder.erase();
			return;
		}

		debug("swallowed");

		builder.append_unichar(keyval);
		swallowed = true;
		commit_string = builder.str;
		chars_to_delete = 1;
	}
}


void on_bus_acquired(DBusConnection conn) {
	print("Bus aquired\n");
	try {
		conn.register_object("/server", new Server());
	} catch (IOError e) {
		stderr.printf(e.message);
	}
}


void main() {
	Bus.own_name(BusType.SESSION,
				 "org.bogo",
				 BusNameOwnerFlags.NONE, on_bus_acquired,
				 () => {},
				 () => { stderr.printf("Cannot acquire name!\n"); });

	new MainLoop().run();
}
