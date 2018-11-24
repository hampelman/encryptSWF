package;


import flash.utils.ByteArray;
import flash.display.Loader;
import flash.system.LoaderContext;
import flash.events.Event;
import flash.Lib;
import flash.system.ApplicationDomain;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.display.Stage;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import haxe.io.Bytes;

class TestSWF
{
  static private var _swfUrl = "../encrypted/test.jpg";
  static private var _stage:Stage;
  static private var _loaderContext: LoaderContext;
  static private var _startTime:Float;
  static private var _numberOfBytes:UInt;

  static public function main()
  {
    #if flash
      _startTime = Date.now().getTime();
      _stage = Lib.current.stage;
      _loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, null);
      loadEncodedSwf();
    #else
      trace('flash only');
    #end
  }


  static private function loadEncodedSwf()
  {
    var encodedBytes = new URLLoader();
    encodedBytes.dataFormat = URLLoaderDataFormat.BINARY;
    encodedBytes.addEventListener(Event.COMPLETE,decodeSwf);
    encodedBytes.load(new URLRequest(_swfUrl));
  }

  //TODO: avoid all the roundabout converting of Bytes
  static private function decodeSwf(e:Event){
    var byteArray:ByteArray = e.target.data;
    _numberOfBytes = byteArray.length;
    //convert BateArray to Bytes
    var encryptedBytes = flashByteArray_to_Bytes(byteArray);
    //now decrypt
    var decryptedBytes = EncryptSWF.decryptBytes(encryptedBytes);
    //convert Bytes to ByteArray
    var swfBytes = bytes_to_flashByteArray(decryptedBytes);
    //load them into a displayObject
    var swf = new Loader();
    swf.contentLoaderInfo.addEventListener(Event.COMPLETE,showSwf);
    swf.loadBytes(swfBytes, _loaderContext);
  }

  static private function showSwf(e:Event){
    //remove listener
    e.target.removeEventListener(Event.COMPLETE,showSwf);
    //add the content to the screen
    _stage.addChild(e.target.content);
    //also show the time needed to encrypte
    showDecryptionTime();
  }

  static private function showDecryptionTime(){
    var now = Date.now().getTime();
    var passed = now - _startTime;
    var message = 'Time spent decrypting ' + _numberOfBytes + ' bytes: ' + Std.string(passed) + ' ms';
    //textField
    var tf:TextField = new TextField();
    tf.text = message;
    //text format
    var format:TextFormat = new TextFormat();
    format.color = 0x00FF00;
    format.font = "Courier";
    format.size = 21;
    tf.setTextFormat(format);
    tf.autoSize = TextFieldAutoSize.CENTER;
    //center align
    tf.x = _stage.stageWidth/2 - tf.width/2;
    tf.y = _stage.stageHeight/2 - tf.height/2;
    //add to stage
    _stage.addChild(tf);
  }


  /* Conversion of Bytes */

  static private function bytes_to_flashByteArray(bytes:Bytes):ByteArray{
    var l = bytes.length;
    var i:Int = 0;
    var bt:Int;
    var btArray:ByteArray = new ByteArray();
    while (i <= l){
      bt = bytes.get(i);
      btArray.writeByte(bt);
      i++;
    }
    return btArray;
  }

  static private function flashByteArray_to_Bytes(ba:ByteArray):Bytes{
    var l = ba.length;
    var i:UInt = 0;
    var bt:Int;
    var bytes:Bytes = Bytes.alloc(l);
    while (i < l){
      bt = ba.readByte();
      bytes.set(i,bt);
      i++;
    }
    return bytes;
  }
}
