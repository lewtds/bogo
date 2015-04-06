[DBus (name = "org.bogo.Server")]
interface BogoServer : Object {
	public abstract void process_key(uint keyval,
									 Gdk.ModifierType modifiers,
									 out uint chars_to_delete,
									 out string commit_string,
									 out bool swallowed) throws IOError;
}


public class BogoIMContext : Gtk.IMContext {
	private Gdk.Window client_window;
	private uint32 last_event_time;
	private string prgname;
	private uint pending_fake_backspaces;
	private string delayed_commit_text;
	private BogoServer server;
	private string composition = "";

	public BogoIMContext() {
		prgname = Environment.get_prgname();
		debug("prgname: %s", prgname);

		try {
			server = Bus.get_proxy_sync(BusType.SESSION,
										"org.bogo", "/server");
			debug("Connected");
		} catch (IOError e) {
			warning("Cannot connect to bogo server");
		}
	}

	public override void set_client_window(Gdk.Window window) {
		client_window = window;
	}
	
	public override bool filter_keypress(Gdk.EventKey event) {
		last_event_time = event.time;

		if (event.type == Gdk.EventType.KEY_RELEASE &&
			event.send_event == 1) { 

			debug("fake release");

			if (pending_fake_backspaces == 0 &&
				delayed_commit_text != "") {

				debug("delayed commit");
				commit(delayed_commit_text);
				delayed_commit_text = "";
			}

			return false;
		}

		if (event.type != Gdk.EventType.KEY_PRESS) {
			return false;
		}

		if (event.send_event == 1) {
			debug("fake press");
			pending_fake_backspaces--;
			return false;
		}

		string output = null;
		uint backspaces;
		bool swallowed;
		server.process_key(event.keyval,
						   event.state,
						   out backspaces,
						   out output,
						   out swallowed);

		if (!swallowed) {
			return false;
		} else {
			update_composition(output);
			return true;
		}
	}

	private void update_composition(string text) {
		// calculate the difference
		int diff_count = composition.length;

		delete_previous_chars(diff_count);
		
		if (pending_fake_backspaces > 0) {
			delayed_commit_text = text;
		} else {
			commit(text);
		}

		composition = text;
	}

	private bool is_app_blacklisted() {
		string[] blacklist = {
			"firefox"
		};

		foreach (var name in blacklist) {
			if (prgname == name) {
				return true;
			}
		}

		return false;
	}

	private void delete_previous_chars(uint count) {
		if (is_app_blacklisted()) {
			delete_with_backspace(count);
		} else {
			var deleted = delete_surrounding(-(int) count, (int) count);
			if (!deleted) {
				debug("delete_surrounding() failed.");
				delete_with_backspace(count);
			}
		}
	}

	private void delete_with_backspace(uint count) {
		for (int i = 0; i < count; i++) {
			send_backspace();
		}

		pending_fake_backspaces += count;
	}

	private void send_backspace() {
		// Somehow the Vala binding breaks if we used
		// Gdk.Key.BackSpace
		fake_key(0xff08, 0);
	}

	private void fake_key(uint keysym, Gdk.ModifierType modifiers) {
		// Convert keysym to keycode
		var keymap = Gdk.Keymap.get_default();
		Gdk.KeymapKey[] keys;
		keymap.get_entries_for_keyval(0xff08, out keys);
		uint16 keycode = 0;

		if (keys.length > 0) {
			keycode = (uint16) keys[0].keycode;
		}

		// Put a key press event into Gdk's event queue
		Gdk.EventKey* press_event = (Gdk.EventKey*) new Gdk.Event(Gdk.EventType.KEY_PRESS);
		press_event->window = client_window;
		press_event->send_event = 1;
		press_event->keyval = keysym;
		press_event->hardware_keycode = keycode;
		press_event->str = "";
		press_event->length = 0;
		press_event->state = modifiers;
		press_event->group = 0;
		press_event->is_modifier = 0;
		press_event->time = last_event_time + 1;

		// And the key release event
		Gdk.EventKey* release_event = (Gdk.EventKey*) ((Gdk.Event) press_event).copy();
		release_event->type = Gdk.EventType.KEY_RELEASE;
		release_event->state = modifiers | Gdk.ModifierType.RELEASE_MASK;
		release_event->time = last_event_time + 2;

		// LOL, chromium is so fucked up here
		if (prgname == "chromium") {
			((Gdk.Event) release_event).put();
			((Gdk.Event) press_event).put();
		} else {
			((Gdk.Event) press_event).put();
			((Gdk.Event) release_event).put();
		}
	}
}