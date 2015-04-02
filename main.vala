public class BogoIMContext : Gtk.IMContext {
	private Gdk.Window client_window;
	private uint32 last_event_time;
	private string prgname;

	public BogoIMContext() {
		prgname = Environment.get_prgname();
		debug("prgname: %s", prgname);

	}

	public override void set_client_window(Gdk.Window window) {
		debug("set_client_window()");
		client_window = window;
	}
	
	public override bool filter_keypress(Gdk.EventKey event) {
		last_event_time = event.time;

		if (event.type != Gdk.EventType.KEY_PRESS ||
			event.send_event == 1) {
			return false;
		}
		
		if (event.keyval != 97) {
			commit("chin");
		} else {
			delete_previous_chars(4);

			commit("cool");
		}

		return true;
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
	}
	
	public override void focus_in() {
		debug("focus_in()");
	}

	public override void focus_out() {
		debug("focus_out()");
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
		var e = (Gdk.EventKey *) new Gdk.Event(Gdk.EventType.KEY_PRESS);
		e.window = client_window;
		e.send_event = 1;
		e.keyval = keysym;
		e.hardware_keycode = keycode;
		e.str = "";
		e.length = 0;
		e.state = modifiers;
		e.group = 0;
		e.is_modifier = 0;
		e.time = last_event_time + 1;

		((Gdk.Event) e).put();

		// And the key release event
		e.type = Gdk.EventType.KEY_RELEASE;
		e.state = modifiers | Gdk.ModifierType.RELEASE_MASK;
		e.time = last_event_time + 2;

		((Gdk.Event) e).put();
	}
}