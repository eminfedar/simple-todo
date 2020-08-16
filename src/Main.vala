using Gtk;
using GLib;

namespace TodoGtk {
    public class App : Gtk.Application {

        public App() {
            Object(
                application_id: "com.eminfedar.simple-todo",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate() {            
            var window = new MainWindow(this);
            window.show_all();
        }
    }

    public static int main(string[] args) {
        var app = new App();
        return app.run(args);
    }
}
