import com.hurlant.util.ByteArray;
import sys.FileSystem;

import com.hurlant.crypto.symmetric.AESKey;
import com.hurlant.util.Hex;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

//for c++ output
#if cplusplus
import cpp.Lib;
#end


class EncryptSWF
{
	/* constants */


	static private var swfDirectory = "unencrypted";
	static private var encryptDirectory = "encrypted";
	static private var fileExtension = "jpg"; // this is a nasty trick (haha!): disguise my swf as a jpg
	static private var hexKey = "2C2D2E2F31323334363738393B3C3D3E"; // fill in your own 128 / 256 bit hexadecimal key

	static public function main()
	{
		if (fileSystemAvailable())
		{
			readFiles();
		}
		else
		{
			trace('no file system functionality available');
		}
	}

	static private function readFiles()
	{

		//encode all file
		for (file in sys.FileSystem.readDirectory(swfDirectory))
		{
			var path = haxe.io.Path.join([swfDirectory, file]);
			var fileName = new haxe.io.Path(path).file;

			if (!sys.FileSystem.isDirectory(path))
			{
				var swfBytes = sys.io.File.getBytes(path);
				var encryptedBytes = encryptBytes(swfBytes);
				//test decrypt bytes
				//var decryptedbytes = decryptBytes(encryptedBytes);
				var encryptedFilename = haxe.io.Path.join([encryptDirectory, fileName + '.' + fileExtension]);
				//write the file
				sys.io.File.saveBytes(encryptedFilename, encryptedBytes);
				var output = 'encoded ' + path + ' to ' + encryptedFilename;

				#if cplusplus
				Lib.println(output);
				#else
				trace(output);
				#end

				/*
				//test: decrypt
				try{
					var decryptedbytes = sys.io.File.getBytes(encryptedFilename);
					var decryptedSwfBytes = decryptBytes(decryptedbytes);
				}catch( msg : String ) {
					trace("Error message : " + msg );
				}
				*/

			}
		}
	}


	static private function encryptBytes(bt:Bytes):Bytes
	{
		var result: BytesBuffer = new BytesBuffer ();
		var key = Hex.toArray(hexKey);
		var aes = new AESKey(key);
		var keyLength = key.length;
		//trace ('Key length: ' + keyLength);
		var block:ByteArray;
		var maxBt = Math.floor(bt.length / keyLength);
		var i = 0;
		while (i < maxBt)
		{
			block = ByteArray.fromBytes(bt.sub(i*keyLength,keyLength));
			trace ('enc: block before : ' + Hex.fromArray(block).toUpperCase());
			//do the encoding
			aes.encrypt(block);
			trace ('enc: block after : ' + Hex.fromArray(block).toUpperCase());
			result.add( block.getBytes());
			i++;
		}
		//also encode bytes left
		var leftBt = bt.length % keyLength;
		if (leftBt > 0)
		{
			block = ByteArray.fromBytes(bt.sub(i * keyLength, leftBt));
			trace ('enc - bytes left : ' + Hex.fromArray(block).toUpperCase());
			aes.encrypt(block);
			trace ('enc - bytes left encoded : ' + Hex.fromArray(block).toUpperCase());
			result.add(block.getBytes());
		}
		//add number leftBt as last byte of the encrypted bytes
		result.addByte(leftBt);
		return result.getBytes();
	}

	static public function decryptBytes(bt:Bytes):Bytes
	{
		var result: BytesBuffer = new BytesBuffer ();
		var key = Hex.toArray(hexKey);
		var aes = new AESKey(key);
		var keyLength = key.length;
		var block:com.hurlant.util.ByteArray;
		var maxBt = Math.floor(bt.length / keyLength);
		var i = 0;
		while (i < maxBt)
		{
			//trace ("i2: " + i);
			block = ByteArray.fromBytes(bt.sub(i*keyLength,keyLength));
			trace ('dec - block encoded : ' + Hex.fromArray(block).toUpperCase());
			//do the encoding
			aes.decrypt(block);
			trace ('dec - block decoded : ' + Hex.fromArray(block).toUpperCase());
			result.add( block.getBytes());
			i++;
		}
		//correct the result with lastBlockLength (stored in extra byte)

		//check if it is actualy the last byte that you read
		var leftBt = bt.length % keyLength;
		if (leftBt > 1) {
			throw ('num of ending bytes (should be 1): ' + leftBt); //this should always be 1!
		}else{
			//read last byte
			var lastBlockLength = bt.get(i * keyLength); //bytes left in last block

			//calculatebytes to subtract from result
			var subtractFromDecoded = (keyLength - lastBlockLength);
			var returnBytes:Bytes = result.getBytes();
			var length = returnBytes.length;
			returnBytes = returnBytes.sub(0, length - subtractFromDecoded);
			// trace ('result : '  + returnBytes.toHex());
			return returnBytes;
		}
	}

	static private function fileSystemAvailable():Bool
	{
		#if sys
		return true;
		#end
		return false;
	}
}
