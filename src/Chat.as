package {
	
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	public class Chat extends Sprite {
		
		private var nc:NetConnection;
		private var so:SharedObject;
		
		private var window:Window;
		private var textArea:TextArea;
		private var textInput:InputText;
		private var connectBut:PushButton;
		
		public function Chat() {
			createWindow();
		}
		
		/**
		 * Create window with preview and controls
		 */
		private function createWindow():void {
			// WINDOW
			window = new Window(null, 5, 180, "CHAT via SharedObject");
			window.hasMinimizeButton = true;
			window.minimized = true;
			
			// HBOX WITH BUTTONS
			var vb:VBox = new VBox(window.content);
			textArea = new TextArea(vb);
			textInput = new InputText(vb);
			textInput.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			connectBut = new PushButton(vb, 0, 0, "CONNECT", onConnect);
			textArea.width = textInput.width = connectBut.width = 150;
			textArea.enabled = textInput.enabled = false;
			
			window.width = textArea.width;
			window.height = textArea.height + textInput.height + connectBut.height + 2*vb.spacing + 20;
			
			addChild(window);
		}
		private function onConnect(e:MouseEvent):void {
			connectBut.enabled = false;
			connect();
		}
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER && textInput.text.length > 0) {
				so.send("onChat", textInput.text);
				textInput.text = "";
			}
		}
		
		/**
		 * Connect to server
		 */
		private function connect():void {
			if (!nc) {
				nc = new NetConnection();
				nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
			nc.connect(Config.SERVER + "/" + Config.APP, Config.SESSION, 142);		// 142 is magic number
		}
		
		/**
		 * NetStatus handler for NetConnection and NetStream
		 * @param e
		 */
		private function onNetStatus(e:NetStatusEvent):void {
			Config.addLog("chat\t", e.info.code);
			switch (e.info.code) {
				case "NetConnection.Connect.Success":
					connectToRemote();
					break;
				case "NetConnection.Connect.Failed":
					textArea.enabled = textInput.enabled = false;
					connectBut.enabled = true;
					connect();
					break;
			}
		}
		
		/**
		 * Connect to remove SharedObject
		 */		
		private function connectToRemote():void {
			so = SharedObject.getRemote("chat", nc.uri);
			so.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			so.addEventListener(SyncEvent.SYNC, onSync);
			so.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onSyncError);
			so.client = new Object();
			so.client.onChat = onChat;
			so.connect(nc);
			
		}
		private function onSync(e:SyncEvent):void {
			textArea.enabled = textInput.enabled = true;
			Config.addLog("chat\t\t", e.type, " ", e.changeList);
		}
		private function onSyncError(e:AsyncErrorEvent):void {
			Config.addLog("chat\t\t", e.type, " ", e.text);
		}
		
		/**
		 * Recieve chat message
		 * @param msg message
		 */		
		private function onChat(msg:String):void {
			textArea.text += msg + "\n";
			setTimeout(function():void {textArea.textField.scrollV = textArea.textField.maxScrollV}, 100);
		}
		
	}
}