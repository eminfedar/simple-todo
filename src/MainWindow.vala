using Gtk;
using GLib;
using Pango;

namespace TodoGtk {

    public class MainWindow : Gtk.Window {
        // Item list
        private Array<TodoItem> itemsList = new Array<TodoItem>();

        // File
        private File file;
        private FileIOStream filestream;

        // Components
        private Box mainBox;

        // Constants:
        private const string line_ticked = "[+]>";
        private const string line_not_ticked = "[-]>";
        private string APPDATA = GLib.Environment.get_user_data_dir();

        public MainWindow(App app) {
            Object(application: app); // Calling the base class constructor

            this.title = "To-Do";
            this.icon_name = "simple-todo";
            this.set_default_size(250,1);

            addComponents();

            readItemsFromFile();
            addItemAppendButton();

            this.show_all();
        }

        private void addComponents() {
            mainBox = new Box(Orientation.VERTICAL, 3);
            mainBox.margin = 7;
            add(mainBox);
        }

        private void addItem(string text, bool isStriked = false) {
            // Create new item:
            TodoItem item = new TodoItem(text, isStriked);
            this.mainBox.add(item);
            this.itemsList.append_val(item);

            // Add signals:
            item.removeItem.connect(() => {
                this.mainBox.remove(item);
                for(var i=0; i < this.itemsList.length; i++)
                    if (this.itemsList.data[i] == item)
                        this.itemsList.remove_index(i);

                this.saveItems();
                this.show_all();
            });
            item.editFinished.connect(() => {
                this.saveItems();
            });

            item.textview.has_focus = true;

            // Show all:
            this.show_all();
        }

        private void readItemsFromFile() throws GLib.Error{
            var folder = File.new_for_path(APPDATA + "/simple-todo/");
            if( !folder.query_exists() ) {
                folder.make_directory_with_parents();
            }

            file = File.new_for_path(APPDATA + "/simple-todo/todo.txt");
            if( !file.query_exists() ) {
                filestream = file.create_readwrite(FileCreateFlags.NONE);
            }
            else {
                filestream = file.open_readwrite();
                var stream = new DataInputStream (filestream.input_stream);
                string line;
                while ((line = stream.read_line()) != null) {
                    if (line.length > 0) {
                        if (line.substring(0, 4) == line_ticked) {
                            addItem(line.substring(4, line.length-4), true);
                        } else if (line.substring(0, 4) == line_not_ticked) {
                            addItem(line.substring(4, line.length-4), false);
                        } else {
                            var item = itemsList.data[itemsList.length-1];
                            item.text = item.text + "\n" + line;

                            this.show_all();
                        }
                    }
                }

            }
        }

        private void addItemAppendButton() {
            var box_item_add = new Box(Orientation.HORIZONTAL, 7);
            var btn_add = new Button();
            var img_add = new Image.from_icon_name("list-add", IconSize.SMALL_TOOLBAR);

            btn_add.add(img_add);
            btn_add.relief = ReliefStyle.NONE;

            btn_add.clicked.connect(() => {
                addItem("", false);
                mainBox.reorder_child(box_item_add, (int)mainBox.get_children().length());
                this.show_all();
            });

            box_item_add.add(btn_add);

            mainBox.add(box_item_add);
        }

        private void saveItems() throws GLib.Error {
            if( file.query_exists() ) {
                file.delete();
                filestream = file.create_readwrite(FileCreateFlags.NONE);
            }
            var stream = new DataOutputStream(filestream.output_stream);

            string data = "";
            for(var i=0; i<itemsList.length; i++) {

                var item = itemsList.data[i];

                data += item.isStriked ? line_ticked + item.text : line_not_ticked + item.text;
                data += "\n";
            }
            stream.put_string(data);
        }
    }
}
