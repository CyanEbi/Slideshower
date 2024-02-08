import 'dart:io';

class Node {
  File value;
  Node? prev;
  Node? next;

  Node(this.value, [this.prev, this.next]);
}
