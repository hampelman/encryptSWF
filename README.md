### What does it do?
Encrypts all files in the directory __unencryped__ with 128 bit AES encryption
and disguises it as a jpg file.

### What does it need?
Haxe of course.
The library *Haxe-crypto*
Decrypting should also work with *Lime* (some redecorating of Byte types will be necessary) if you want to target *AIR* and want to make use of Lime's nice Asset system. I've got things working in *OpenFl*, however with Haxe's flash classes and not OpenFl's swf-lite. 

### Testing use
Only to use with small files, unless you like waiting and many lines of hexadecimal output.
Gives some extra trace output.
`haxe run.hxml`

### Production use
Compile to cpp `haxe cpp.hxml`.
Put your swfs in de directory __unencrypted__.
Start encrypting your files with `bin/EncryptSWF`.

### Testing the result
First encrypt *test.swf*
Then compile *TestSwf.hx* with the command `haxe test.hxml`
Test *bin/decryptAndShowSwf.swf* in the **Flash Player Debugger**

### Who made this
This is made by Fabian de Boer
(fabian@hampelman.nl)
