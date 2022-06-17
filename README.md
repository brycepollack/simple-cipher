# BookEncrypter
This encrypter takes in a book as a .txt file and a message as arguments and uses the book as a cipher to encrypt the message.
There are 2 versions: a C version and an assembly (ARM64) version.

Command line arguments:
Arm version: ./encrypter (-d|-e) -b <bookfile> <encryption_file>
C version: ./Cencrypter (-d|-e) -b <bookfile> <encryption_file>

Makefile is for the test harness and a number of tests are included to help me with debugging.
