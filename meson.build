# project name and programming language
project('simple-todo', 'vala', 'c', version: '1.0.0')

# add resources to the executeable
gnome = import('gnome')
resources = gnome.compile_resources(
    meson.project_name() + '-resources',
    'data/resources.xml',
    c_name: 'resources'
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src/TodoItem.vala',
    'src/MainWindow.vala',
    'src/Main.vala',
    resources,

    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gio-2.0'),
    ],
    install: true
)

#Install our .desktop file so the Applications Menu will see it
install_data(
    join_paths('data', meson.project_name() + '.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)
