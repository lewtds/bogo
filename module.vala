// This file declares functions that are called by Gtk+ to handle
// life-cycle events of the whole shared module.

public void im_module_list (out Gtk.IMContextInfo*[] contexts) {
	// FIXME: Potentially dangerous as `context` is created on stack
	//        and referred to even after this function returns.
	var context = Gtk.IMContextInfo() {
		context_id = "bogo",
		context_name = "Bogo Vietnamese input method",
		domain = "bogo",
		domain_dirname = "",
		default_locales = "vi"
	};

	contexts = {
		&context
	};
}


// Use [ModuleInit] so that Vala generates code that uses g_type_module_register_type().
// https://mail.gnome.org/archives/vala-list/2008-December/msg00081.html
[ModuleInit]
public void im_module_init (TypeModule type_module) {
}

public void im_module_exit () {
}

public Gtk.IMContext im_module_create (string context_id) {
	return new BogoIMContext();
}
