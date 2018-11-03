### What does it do?
Encrypts all files in the directory __unencryped__ with 128 bit AES encryption
and disguises it as a jpg file.

### What does it need?
Haxe of course.
The library *haxe-crypto*

### Testing use
Only to use with small files, unless you like waiting and many lines of Hexadecimal output.
Gives some extra trace output
`haxe run.hxml`

### Production use
Compile to cpp `haxe cpp.hxml`
Put your swfs in de directory __unencrypted__
Start encrypting your files with `bin/EncryptSWF`

### Who made this
This is made by Fabian de Boer
(fabian@hampelman.nl)
