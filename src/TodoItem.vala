using Gtk;
using GLib;
using Pango;

namespace TodoGtk {

    public enum LabelMode{
        Text,
        Edit
    }

    public class TodoItem : Gtk.Box {
        // Get-Sets:
        private bool m_isUnderlined = false;
        public bool isUnderlined {get {return m_isUnderlined;} set {
            m_isUnderlined = value;

            this.text = this.text;
        }}
        private bool m_isStriked = false;
        public bool isStriked {get {return m_isStriked;} set {
            m_isStriked = value;

            this.text = this.text;
        }}

        private string m_text = "";
        public string text {get { return m_text; } set {
            m_text = value;

            string pre = "", post = "";
            if (this.isUnderlined){
                pre = "<u>";
                post = "</u>";
            }
            if (this.isStriked) {
                pre = pre + "<s>";
                post = "</s>" + post;
            }
            this.label.set_markup(pre + m_text + post);
        }}

        // Components
        CheckButton checkbutton = new CheckButton.with_label("");
        Label label = new Label("");
        Stack stack = new Stack();
        EventBox eb_label = new EventBox();
        public TextView textview = new TextView();

        Gtk.Menu rightClickMenu = new Gtk.Menu();


        // Signal
        public signal void removeItem();
        public signal void editFinished();

        public TodoItem(string text, bool isChecked) {
            Object(orientation:Orientation.HORIZONTAL, spacing:0);

            this.isStriked = isChecked;
            this.text = text;

            this.addRightClickMenu();
            this.addComponents();
            this.addComponentSignals();
            this.setComponentProperties();
        }

        private void addRightClickMenu() {
            Gtk.MenuItem removeItem = new Gtk.MenuItem();
            removeItem.label = "Remove";
            removeItem.activate.connect(() => {
                this.removeItem();
            });
            rightClickMenu.append(removeItem);
            removeItem.show();
        }

        private void addComponents() {
            textview.buffer.text = this.text;

            eb_label.add(label);

            if (this.text.length > 0) {
                stack.add_named(eb_label, "label");
                stack.add_named(textview, "textview");
            } else {
                stack.add_named(textview, "textview");
                stack.add_named(eb_label, "label");
            }

            add(checkbutton);
            pack_start(stack, true, true, 0);
        }

        private void addComponentSignals() {
            // EventBox Label
            eb_label.enter_notify_event.connect((e) => {
                this.isUnderlined = true;
                return false;
            });
            eb_label.leave_notify_event.connect((e) => {
                this.isUnderlined = false;
                return false;
            });
            eb_label.button_press_event.connect((e) => {
                uint pressedButton;
                e.get_button(out pressedButton);

                if (pressedButton == Gdk.BUTTON_PRIMARY) {
                    setMode(LabelMode.Edit);
                } else if (pressedButton == Gdk.BUTTON_SECONDARY) {
                    rightClickMenu.popup_at_pointer();
                }

                return false;
            });

            // Checkbutton
            checkbutton.clicked.connect(() => {
                this.isStriked = checkbutton.active;
                editFinished();
            });

            // Textview
            textview.key_press_event.connect((e) => {
                if ( e.keyval == Gdk.Key.Escape || (e.keyval == Gdk.Key.Return && (e.state & Gdk.ModifierType.SHIFT_MASK) != 1) ) {
                    setMode(LabelMode.Text);
                    return true;
                }

                return false;
            });
            textview.focus_out_event.connect((e) => {
                setMode(LabelMode.Text);
                return false;
            });
        }

        private void setComponentProperties() {
            // Checkbutton
            checkbutton.set_active(isStriked);

            // Label
            label.halign = Align.START;
            label.justify = Justification.LEFT;

            // TextView
            textview.margin_top = 2;
        }

        public void setMode(LabelMode mode) {
            if(mode == LabelMode.Text) {
                stack.set_visible_child_name("label");

                this.text = textview.buffer.text;

                editFinished();

                if (textview.buffer.text.length == 0) {
                    // Delete request
                    this.removeItem();
                }
            } else {
                stack.set_visible_child_name("textview");

                textview.has_focus = true;
                textview.buffer.text = this.text;
            }
        }
    }
}
