package;
import haxe.ds.Vector;
import haxe.io.Bytes;
import js.Browser;
import js.html.Blob;
import js.html.Int8Array;
import haxe.io.UInt8Array;
/**
 * ...
 * @author YellowAfterlife
 */
class Tools {
	public static function base64of(bytes:Bytes, offset:Int, length:Int) {
		var pos = 0;
		var raw = "";
		while (pos < length) {
			var end = pos + 0x8000;
			if (end > length) end = length;
			var sub = UInt8Array.fromBytes(bytes, offset + pos, end - pos);
			raw += untyped js.Syntax.code("String.fromCharCode.apply(null, {0})", sub);
			pos = end;
		}
		return Browser.window.btoa(raw);
	}
	public static function bytesOfBase64(base64:String) {
		var data = Browser.window.atob(base64);
		var out = Bytes.alloc(data.length);
		for (i in 0 ... data.length) {
			out.set(i, StringTools.fastCodeAt(data, i));
		}
		return out;
	}
	public static function bytesOfDataURL(dataURL:String) {
		return bytesOfBase64(dataURL.substring(dataURL.indexOf(",") + 1));
	}
	public static function bytesToBlobURL(bytes:Bytes, path:String, type:String):String {
		try {
			var blob:Blob = new Blob([bytes.getData()], { type: type });
			//
			var nav:Dynamic = Browser.navigator;
			if (nav.msSaveBlob != null) {
				nav.msSaveBlob(blob, path);
				return null;
			}
			//
			return js.html.URL.createObjectURL(blob);
		} catch (err:Dynamic) {
			Browser.window.console.error("Failed to make blob", err);
			return "data:" + type + ";base64," + base64of(bytes, 0, bytes.length);
		}
	}
}
