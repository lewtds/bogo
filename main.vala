public class BogoIMContext : Gtk.IMContext {

	public BogoIMContext() {
		print("%s\n", Environment.get_prgname());
	}
	
	public override bool filter_keypress(Gdk.EventKey event) {
		if (event.keyval != 97) {
			commit("chin");
		} else {
			bool deleted = delete_surrounding(-4, 4);
			commit("cool");
			print(@"$deleted\n");
		}
		return true;
	}
	
	public override void focus_in() {
		print("focus_in()\n");
	}

	public override void focus_out() {
		print("focus_out()\n");
	}
}