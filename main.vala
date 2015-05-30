/* -*- indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */

namespace Bogo {

  [DBus (name = "org.bogo.Server")]
  public interface Server : Object {
    public abstract int create_input_context() throws IOError;
  }

  [DBus (name = "org.bogo.InputContext")]
  public interface InputContext : Object {
    public abstract bool process_key(uint keyval,
                                     Gdk.ModifierType modifiers) throws IOError;
    public abstract void reset() throws IOError;
    public signal void composition_updated(string text, uint chars_to_delete);
  }
}


// This class will both commit and delete previous text by forwarding key events.
public class ForwardKeyEventIMContext : BogoIMContext {
  public ForwardKeyEventIMContext(string program_name, Bogo.InputContext ctx) {
    base(program_name, ctx);
    input_ctx.composition_updated.connect(update_composition);
  }

  public override bool filter_keypress(Gdk.EventKey event) {
    last_event_time = event.time;

    if (is_fake_event(event)) {
      return false;
    }

    if (event.type != Gdk.EventType.KEY_PRESS) {
      return false;
    }

    debug(@"KEY_PRESS: $(event.keyval)");
    bool swallowed = input_ctx.process_key(event.keyval, event.state);
    return swallowed;
  }

  private void update_composition(string text, uint chars_to_delete) {
    debug(@"update_composition($text, $chars_to_delete)");
    delete_with_backspace(chars_to_delete);
    commit_by_forwarding(text);
  }

  private void commit_by_forwarding(string text) {
    unichar c;
    for (int i = 0; text.get_next_char(ref i, out c);) {
      uint keysym = unichar_to_keysym(c);

      debug("Send fake key 0x%x".printf(keysym));
      
      fake_key(keysym, 0);
    }
  }

  private uint unichar_to_keysym(unichar c) {
    unichar[] chars = 
      {'Ạ', 'ạ', 'Ả', 'ả', 'Ấ', 'ấ', 'Ầ', 'ầ', 'Ẩ', 'ẩ',
       'Ẫ', 'ẫ', 'Ậ', 'ậ', 'Ắ', 'ắ', 'Ằ', 'ằ', 'Ẳ', 'ẳ',
       'Ẵ', 'ẵ', 'Ặ', 'ặ', 'Ẹ', 'ẹ', 'Ẻ', 'ẻ', 'Ẽ', 'ẽ',
       'Ế', 'ế', 'Ề', 'ề', 'Ể', 'ể', 'Ễ', 'ễ', 'Ệ', 'ệ',
       'Ỉ', 'ỉ', 'Ị', 'ị', 'Ọ', 'ọ', 'Ỏ', 'ỏ', 'Ố', 'ố',
       'Ồ', 'ồ', 'Ổ', 'ổ', 'Ỗ', 'ỗ', 'Ộ', 'ộ', 'Ớ', 'ớ',
       'Ờ', 'ờ', 'Ở', 'ở', 'Ỡ', 'ỡ', 'Ợ', 'ợ', 'Ụ', 'ụ',
       'Ủ', 'ủ', 'Ứ', 'ứ', 'Ừ', 'ừ', 'Ử', 'ử', 'Ữ', 'ữ',
       'Ự', 'ự', 'Ỵ', 'ỵ', 'Ỷ', 'ỷ', 'Ỹ', 'ỹ', 'Ơ', 'ơ',
       'Ư', 'ư', 'ă', 'Ă', 'Ỳ', 'ỳ', 'Đ', 'đ', 'Ĩ', 'ĩ',
       'Ũ', 'ũ'};

    int[] keysyms = 
      {0x1001ea0, 0x1001ea1, 0x1001ea2, 0x1001ea3,
       0x1001ea4, 0x1001ea5, 0x1001ea6, 0x1001ea7,
       0x1001ea8, 0x1001ea9, 0x1001eaa, 0x1001eab,
       0x1001eac, 0x1001ead, 0x1001eae, 0x1001eaf,
       0x1001eb0, 0x1001eb1, 0x1001eb2, 0x1001eb3,
       0x1001eb4, 0x1001eb5, 0x1001eb6, 0x1001eb7,
       0x1001eb8, 0x1001eb9, 0x1001eba, 0x1001ebb,
       0x1001ebc, 0x1001ebd, 0x1001ebe, 0x1001ebf,
       0x1001ec0, 0x1001ec1, 0x1001ec2, 0x1001ec3,
       0x1001ec4, 0x1001ec5, 0x1001ec6, 0x1001ec7,
       0x1001ec8, 0x1001ec9, 0x1001eca, 0x1001ecb,
       0x1001ecc, 0x1001ecd, 0x1001ece, 0x1001ecf,
       0x1001ed0, 0x1001ed1, 0x1001ed2, 0x1001ed3,
       0x1001ed4, 0x1001ed5, 0x1001ed6, 0x1001ed7,
       0x1001ed8, 0x1001ed9, 0x1001eda, 0x1001edb,
       0x1001edc, 0x1001edd, 0x1001ede, 0x1001edf,
       0x1001ee0, 0x1001ee1, 0x1001ee2, 0x1001ee3,
       0x1001ee4, 0x1001ee5, 0x1001ee6, 0x1001ee7,
       0x1001ee8, 0x1001ee9, 0x1001eea, 0x1001eeb,
       0x1001eec, 0x1001eed, 0x1001eee, 0x1001eef,
       0x1001ef0, 0x1001ef1, 0x1001ef4, 0x1001ef5,
       0x1001ef6, 0x1001ef7, 0x1001ef8, 0x1001ef9,
       0x10001a0, 0x10001a1, 0x10001af, 0x10001b0,
       0x01e3, 0x01c3, 0x1001ef2, 0x1001ef3,
       0x01d0, 0x01f0, 0x03a5, 0x03b5,
       0x03dd, 0x03fd};

    for (int i = 0; i < chars.length; i++) {
      if (chars[i] == c) {
        return keysyms[i];
      }
    }

    return c;
  }
}

// This class deletes previous text by sending backspaces
// but uses Gtk.IMContext.commit()
public class BackspaceRealCommitIMContext : BogoIMContext {
  private string composition = "";
  private string delayed_commit_text = "";

  public BackspaceRealCommitIMContext(string program_name, Bogo.InputContext ctx) {
    base(program_name, ctx);
    input_ctx.composition_updated.connect(update_composition);
  }

  public override bool filter_keypress(Gdk.EventKey event) {
    last_event_time = event.time;

    if (event.hardware_keycode == 255 &&
        (event.state & (1 << 24)) != 0) { 
      // Sentinel received, commit
      debug(@"delayed commit: $delayed_commit_text");
      commit(delayed_commit_text);
      delayed_commit_text = "";
      return true;
    }

    debug(@"filter($(event.keyval))");

    if (event.keyval == 0xff08 &&
        is_fake_event(event)) {

      if (event.type == Gdk.EventType.KEY_RELEASE) {
        pending_fake_backspaces--;

        if (pending_fake_backspaces == 0 &&
            delayed_commit_text != "") {
          // Last fake backspace release received
          // Send a sentinel event to trigger the delayed commit
          debug("Last fake release, sending sentinel");
        
          Gdk.EventKey* sentinel =
          (Gdk.EventKey*) new Gdk.Event(Gdk.EventType.KEY_PRESS);
          sentinel->window = client_window;
          sentinel->state = (Gdk.ModifierType) 1 << 24;
          sentinel->time = last_event_time + 1;
          sentinel->hardware_keycode = 255;
          sentinel->send_event = 1;
          sentinel->str = "";
          sentinel->group = 0;
          sentinel->is_modifier = 0;
          ((Gdk.Event*) sentinel)->put();
        }
      }

      return false;
    }

    if (event.type != Gdk.EventType.KEY_PRESS) {
      return false;
    }

    bool swallowed = input_ctx.process_key(event.keyval, event.state);
    return swallowed;
  }

  private void update_composition(string text, uint chars_to_delete) {
    debug(@"update_composition($text, $chars_to_delete)");
    delete_previous_chars(chars_to_delete);

    if (pending_fake_backspaces > 0 || delayed_commit_text != "") {
      debug(@"delaying commit($text)");
      delayed_commit_text += text;
    } else {
      debug(@"commit($text)");
      commit(text);
    }

    composition = text;
  }

  private bool is_app_blacklisted() {
    string[] blacklist = {
      "soffice",
      "firefox",
      "gnome-shell"
    };

    foreach (var name in blacklist) {
      if (prgname == name) {
        return true;
      }
    }

    return false;
  }

  private void delete_previous_chars(uint count) {
    if (count == 0) {
      return;
    }

    // If there is pending commit text, delete chars inside it first
    if (has_delayed_commit()) {
      debug("delete_previous_commit() while still have delayed commit");
      int str_count = delayed_commit_text.char_count();
      if (count > str_count) {
        delayed_commit_text = "";
        count -= str_count;
      } else {
        int end_index = str_count - (int) count;
        int end_byte_index = delayed_commit_text.index_of_nth_char(end_index);
        delayed_commit_text = delayed_commit_text.substring(0, end_byte_index);
        return;
      }
    }

    debug(@"delete($count)");

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

  private bool has_delayed_commit() {
    return delayed_commit_text != "";
  }
}

public class BogoIMContext : Gtk.IMContext {
  protected Gdk.Window client_window;
  protected uint32 last_event_time;
  protected string prgname;
  protected Bogo.InputContext input_ctx;
  protected uint pending_fake_backspaces;

  public BogoIMContext(string program_name, Bogo.InputContext ctx) {
    debug("prgname: %s", program_name);
    prgname = program_name;
    input_ctx = ctx;
  }

  ~BogoIMContext() {
    debug("destroyed()");
  }

  protected void delete_with_backspace(uint count) {
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

  protected void fake_key(uint keysym, Gdk.ModifierType modifiers) {
    // Convert keysym to keycode
    var keymap = Gdk.Keymap.get_default();
    Gdk.KeymapKey[] keys;
    keymap.get_entries_for_keyval(keysym, out keys);
    uint16 keycode = 0;

    if (keys.length > 0) {
      keycode = (uint16) keys[0].keycode;
    }

    // Put a key press event into Gdk's event queue
    Gdk.EventKey* press_event =
      (Gdk.EventKey*) new Gdk.Event(Gdk.EventType.KEY_PRESS);
    press_event->window = client_window;
    press_event->send_event = 1;
    press_event->keyval = keysym;
    press_event->hardware_keycode = keycode;
    press_event->str = "";
    press_event->length = 0;
    press_event->state = modifiers | 1 << 25;
    press_event->group = 0;
    press_event->is_modifier = 0;
    press_event->time = last_event_time + 1;

    // And the key release event
    Gdk.EventKey* release_event =
      (Gdk.EventKey*) ((Gdk.Event) press_event).copy();
    release_event->type = Gdk.EventType.KEY_RELEASE;
    release_event->state = release_event->state | Gdk.ModifierType.RELEASE_MASK;
    release_event->time = last_event_time + 2;

    // LOL, chromium is so fucked up here
    if (prgname == "chromium" || prgname == "google-chrome-stable") {
      ((Gdk.Event) release_event).put();
      ((Gdk.Event) press_event).put();
    } else {
      ((Gdk.Event) press_event).put();
      ((Gdk.Event) release_event).put();
    }
  }

  protected bool is_fake_event(Gdk.EventKey e) {
    return (e.state & (1 << 25)) != 0;
  }

  public override void set_client_window(Gdk.Window window) {
    client_window = window;
  }
}
