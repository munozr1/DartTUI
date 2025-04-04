import 'dart:io';

void toascii(String text) {
  text = text.toUpperCase();

  for (int i = 0; i < text.length; i++) {
    switch (text[i]) {
      case 'D':
        printD();
        break;
      case 'A':
        printA();
        break;
      case 'R':
        printR();
        break;
      case 'T':
        printT();
        break;
      default:
        print("Character '${text[i]}' not supported.");
        return;
    }
    if (i < text.length - 1) {
        stdout.write("  ");
    }
  }
  print("");
}

void printD() {
  stdout.write("""
DDDDDD
DD  DD
DD  DD
DD  DD
DDDDDD
""");
}

void printA() {
  stdout.write("""
  AAAA
 AA  AA
 AAAAAA
 AA  AA
 AA  AA
""");
}

void printR() {
  stdout.write("""
RRRRRR
RR  RR
RRRRRR
RR  RR
RR  RR
""");
}

void printT() {
  stdout.write("""
TTTTTT
  TT
  TT
  TT
  TT
""");
}
