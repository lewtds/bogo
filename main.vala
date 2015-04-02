public class BogoIMContext : Gtk.IMContext {
	private Gdk.Window client_window;
	private uint32 last_event_time;

	public BogoIMContext() {
		debug("prgname: %s", Environment.get_prgname());
	}

	public override void set_client_window(Gdk.Window window) {
		debug("set_client_window()");
		client_window = window;
	}
	
	public override bool filter_keypress(Gdk.EventKey event) {
		last_event_time = event.time;

		if (event.type != Gdk.EventType.KEY_PRESS) {
			return false;
		}
		
		if (event.keyval != 97) {
			commit("chin");
		} else {
			debug("delete_surrounding()");

			fake_key(0xff0d, 0);
			// for (int i = 0; i < 4; i++) {
			// 	send_backspace();
			// }
			// bool deleted = delete_surrounding(-4, 4);

			// if (!deleted) {
			// 	debug("delete_surrounding() failed. Sending backspaces.");
			// 	for (int i = 0; i < 0; i++) {
			// 		send_backspace();
			// 	}
			// }

			commit("cool");
		}

		return true;
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