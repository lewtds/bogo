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

public class BogoIMContext : Gtk.IMContext {
  private Gdk.Window client_window;
  private uint32 last_event_time;
  private string prgname;
  private uint pending_fake_backspaces;
  private string delayed_commit_text = "";
  private Bogo.InputContext input_ctx;
  private string composition = "";

  public BogoIMContext(string program_name, Bogo.InputContext ctx) {
    debug("prgname: %s", program_name);
    prgname = program_name;

    input_ctx = ctx;
    input_ctx.composition_updated.connect(update_composition);
  }

  ~BogoIMContext() {
    debug("destroyed()");
  }

  public override void set_client_window(Gdk.Window window) {
    client_window = window;
  }

  public override void focus_in() {
  }

  public override void focus_out() {
  }

  public override void reset() {

    // Firefox will throws reset() when it sees our fake key so we
    // will not actually reset if we're still waiting for the
    // delayed commit.
    // if (!has_delayed_commit()) {
    // 	input_ctx.reset();
    // }
  }

  public override void set_cursor_location(Gdk.Rectangle area) {
    debug("set_cursor_location()");
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

    delete_with_backspace(count);
    // if (is_app_blacklisted()) {
    //   delete_with_backspace(count);
    // } else {
    //   var deleted = delete_surrounding(-(int) count, (int) count);
    //   if (!deleted) {
    //     debug("delete_surrounding() failed.");
    //     delete_with_backspace(count);
    //   }
    // }
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

  private bool has_delayed_commit() {
    return delayed_commit_text != "";
  }

  private bool is_fake_event(Gdk.EventKey e) {
    return (e.state & (1 << 25)) != 0;
  }
}
