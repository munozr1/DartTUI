import 'dart:io';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'package:path/path.dart' as path;
import 'dart:math';

typedef winsize_c = ffi.Pointer<ffi.Uint16> Function();
typedef winsize_d = ffi.Pointer<ffi.Uint16> Function();
typedef free_c = ffi.Void Function(ffi.Pointer);
typedef free_d = void Function(ffi.Pointer);
typedef set_console_mode_c = ffi.Int32 Function(ffi.Int32);
typedef set_console_mode_d = int Function(int);
typedef get_console_mode_c = ffi.Int32 Function();
typedef get_console_mode_d = int Function();

String diamond      = "◇";
String pipe         = "│";
String hook         = "└";
String circle       = "○";
String dot          = "●";

class IMenu {
  // list of menu options
  List<String> options = ["Windows", "MacOS", "Linux", "iOS", "Android"];
  // currently selected option index
  int selected = 1;
  // terminal rows and columns
  int rows = 0;
  int cols = 0;

  late ffi.DynamicLibrary _dylib;
  late set_console_mode_d _setConsoleMode;
  late get_console_mode_d _getConsoleMode;

  // constructor to initialize terminal size
  IMenu() {
    _initTerminalSize();
  }

  // private function to initialize terminal size using dynamic library
  void _initTerminalSize() {
    // Get the absolute path to the current directory
    final currentDir = Directory.current.absolute.path;
    
    // determine library path based on platform
    var libraryPath = path.join(
      currentDir,
      'utils',
      'lib',
      'libwinsize.so',
    );

    if (Platform.isMacOS) {
      libraryPath = path.join(
        currentDir,
        'utils',
        'lib',
        'libwinsize.dylib',
      );
    }

    if (Platform.isWindows) {
      libraryPath = path.join(
        currentDir,
        'utils',
        'lib',
        'winsize.dll',
      );
    }

    // debug
    // print('Attempting to load library from: $libraryPath');
    // print('Current working directory: $currentDir');

    try {
      // check if library exists
      if (!File(libraryPath).existsSync()) {
        throw Exception('Library file not found at: $libraryPath');
      }

      // open library
      _dylib = ffi.DynamicLibrary.open(libraryPath);
      print('Successfully loaded library');
      
      final winsizeFunc = _dylib.lookupFunction<winsize_c, winsize_d>('winsize');
      final freeFunc = _dylib.lookupFunction<free_c, free_d>('free_memory');
      _setConsoleMode = _dylib.lookupFunction<set_console_mode_c, set_console_mode_d>('set_console_mode');
      _getConsoleMode = _dylib.lookupFunction<get_console_mode_c, get_console_mode_d>('get_console_mode');

      // call winsize function
      final resultPointer = winsizeFunc();

      if (resultPointer != ffi.nullptr) {
        rows = resultPointer[0];
        cols = resultPointer[1];
        // print('Terminal size: $rows rows x $cols columns');
        // clean up
        freeFunc(resultPointer);
      } else {
        throw Exception("winsize() returned NULL. Library error.");
      }
    } catch (e, stackTrace) {
      print('Error loading library or calling function: $e');
      print('Stack trace: $stackTrace');
      // fallback values
      rows = 30;
      cols = 80;
      print('Using default terminal size: $rows rows x $cols columns');
    }
  }

  // function to set cursor visibility
  void setCursorVisible(bool visible) {
    stdout.write(visible ? '\x1b[?25h' : '\x1b[?25l');
  }

  // function to set cursor position
  void setCursor(int row, int col) {
    stdout.write('\x1b[${row};${col}H');
  }

  // function to read ansi input
  String readAnsi() {
    if (Platform.isWindows) {
      // windows termnal echo off
      _setConsoleMode(0);  // Disable echo and line input
      int char = stdin.readByteSync();
      _setConsoleMode(1);  // Re-enable echo and line input
      if (char == 13) return '\n';  // Convert CR to LF
      return String.fromCharCode(char);
    }

    // unix termnal echo off
    stdin.echoMode = false;
    stdin.lineMode = false;

    List<int> bytes = [];

    while (true) {
      int byte = stdin.readByteSync();
      bytes.add(byte);

      if (bytes.length == 2 && bytes[0] == 27 && bytes[1] == 91) {
        continue;
      }

      if (bytes.length >= 3 && bytes[0] == 27 && bytes[1] == 91) {
        if ((bytes[bytes.length - 1] >= 65 && bytes[bytes.length - 1] <= 68) ||
            bytes[bytes.length - 1] == 79) {
          stdin.echoMode = true;
          stdin.lineMode = true;
          return utf8.decode(bytes);
        }
      }

      if (bytes.length == 1) {
        stdin.echoMode = true;
        stdin.lineMode = true;
        return utf8.decode(bytes);
      }
    }
  }

  // function to move cursor down
  void down(int n) {
    if (n <= 0) return;
    stdout.write('\x1b[${n}B');
  }

  // function to move cursor up
  void up(int n) {
    if (n <= 0) return;
    stdout.write('\x1b[${n}A');
  }

  //dim text
  String dim(String text) {
    return '\x1b[2m$text\x1b[0m\n';
  }

  String select(String text) {
    return '$pipe  $dot $text';
  }
  String unselect(String text) {
    return '$pipe  $circle $text';
  }

  void displayMenu(bool ok) {
    if (Platform.isWindows) {
      stdout.write(ok ? '\x1b[32m◇\x1b[0m  Select target: (w/s to navigate)\n' : dim('$diamond Select target: (w/s to navigate)'));
    } else {
      stdout.write(ok ? '\x1b[32m◇\x1b[0m  Select target: (j/k to navigate)\n' : dim('$diamond Select target: (j/k to navigate)'));
    }

    for (final entry in options.asMap().entries) {
      int idx = entry.key;
      String option = entry.value;
      print(selected == idx ? select(option) : unselect(option));
    }
    up(options.length);
  }

  // main loop function to display menu and get users selection
  int _handleInput() {
    setCursorVisible(false);
    while (true) {
      displayMenu(false);

      up(1);
      String input = readAnsi();
      String? name = keynames[input];
      switch (name) {
        case 'up':
          selected = max(0, selected - 1);
          break;
        case 'down':
          selected = min(options.length - 1, selected + 1);
          break;
      }

      if (name == 'q' || name == 'enter') {
        displayMenu(true);
        down(options.length + 1);
        break;
      }
    }
    setCursorVisible(true);
    return selected;
  }

  //function to run menu and return selected option
  String run() {
    int selectedIndex = _handleInput();
    return options[selectedIndex];
  }

// ansi sequences
  final keynames = {
    '\x1b[A': 'up',
    'k': 'up',
    '\x1b[B': 'down',
    'j': 'down',
    '\r': 'enter',
    '\n': 'enter',
    'w': 'up',      
    's': 'down',    
    'q': 'q',
  };
}

void main() {
  // create an instance of the IMenu class
  final menu = IMenu();
  // run the menu and get the selected option
  String selectedOption = menu.run();
  // print the selected option
  print('Selected option: $selectedOption');
}






