// -*- indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*-

Python.Object process_sequence_func = null;


[DBus (name = "org.bogo.InputContext")]
public class InputContext : Object {
  private StringBuilder key_sequence;
  private string composition;

  public InputContext() {
    this.key_sequence = new StringBuilder();
  }

  public void destroy() {
    debug("Destroyed");
  }

  public bool process_key(uint keyval, Gdk.ModifierType modifiers) {
    if ((modifiers & (Gdk.ModifierType.CONTROL_MASK)) != 0 ||
        keyval > 128) {
      reset();
      return false;
    }

    key_sequence.append_unichar(keyval);

    var args = Python.Object.build_value("(s)", key_sequence.str);
    var result = (Python.Unicode) process_sequence_func.call(args);
    var new_comp = result.as_utf8();

    if (composition == null) {
      composition_updated(new_comp, 0);
      composition = new_comp;
      return true;
    }

    // Calculate the difference between the new and current compositions
    uint same_chars = 0;
    int i = 0;
    int k = 0;
    unichar old_c;
    unichar new_c;

    while (true) {
      new_comp.get_next_char(ref i, out new_c);
      composition.get_next_char(ref k, out old_c);

      if (new_c != old_c) {
        break;
      }

      same_chars++;
    }

    uint backspaces = composition.char_count() - same_chars;
    string to_commit =
      new_comp.substring(new_comp.index_of_nth_char(same_chars));
    debug(@"'$composition' : '$new_comp'");
    debug(@"same: $same_chars backspaces: $backspaces to commit: $to_commit");
    composition_updated(to_commit, backspaces);

    composition = new_comp;
    return true;
  }

  public void reset() {
    key_sequence.erase();
    composition = "";
  }

  public signal void composition_updated(string text,
                                         uint chars_to_delete);
}

[DBus (name = "org.bogo.Server")]
public class Server : Object {
  private DBusConnection conn;
  private int context_count = 0;

  public Server(DBusConnection conn) {
    this.conn = conn;
  }

  public int create_input_context() {
    try {
      conn.register_object(@"/input_context/$context_count",
                           new InputContext());
      return context_count++;
    } catch (IOError e) {
      stderr.printf(e.message);
      return -1;
    }
  }
}


void on_bus_acquired(DBusConnection conn) {
  print("Bus aquired\n");
  try {
    conn.register_object("/server", new Server(conn));
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

  Python.initialize_ex(0);
  var bogo_module = Python.Import.import_module("bogo");
  process_sequence_func = bogo_module.get_attr_string("process_sequence");

  new MainLoop().run();

  Python.finalize();
}
