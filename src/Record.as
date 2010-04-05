package {
	
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class Record extends Sprite {
		
		private var window:Window;
		private var v:Video;
		private var connectBut:PushButton;
		private var liveBut:PushButton;
		private var recordBut:PushButton;
		
		private var nc:NetConnection;
		private var ns:NetStream;
		private var c:Camera;
		private var m:Microphone;
		
		public function Record() {
			createWindow();
		}
		
		/**
		 * Create window with preview and controls
		 */
		private function createWindow():void {
			// WINDOW
			window = new Window(null, 215, 30, "LIVE Broadcasting and RECORD");
			window.hasMinimizeButton = true;
			window.minimized = true;
			
			// VIDEO
			v = new Video(200, 150);
			v.smoothing = true;
			v.x = v.y = 10;
			window.content.addChild(v);
			
			// HBOX WITH BUTTONS
			var hb:HBox = new HBox(window.content, 10, v.height + 20);
			connectBut = new PushButton(hb, 0, 0, "CONNECT", onConnect);
			liveBut = new PushButton(hb, 0, 0, "LIVE");
			liveBut.addEventListener(MouseEvent.CLICK, onLive);
			recordBut = new PushButton(hb, 0, 0, "RECORD");
			recordBut.addEventListener(MouseEvent.CLICK, onRecord);
			connectBut.width = liveBut.width = recordBut.width = 63;
			liveBut.enabled = recordBut.enabled = false;
			
			window.width = 2*hb.x + v.width;
			window.height = hb.y + connectBut.height + 30;
			
			addChild(window);
		}
		private function onConnect(e:MouseEvent):void {
			connect()
		}
		private function onLive(e:MouseEvent):void {
			start("live");
		}
		private function onRecord(e:MouseEvent):void {
			start("record");
		}
		
		/**
		 * Connect to server
		 */
		private function connect():void {
			if (!nc) {
				nc = new NetConnection();
				nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
			nc.connect(Config.SERVER, Config.SESSION, 142);		// 142 is magic number
			connectBut.enabled = false;
		}
		
		/**
		 * NetStatus handler for NetConnection and NetStream
		 * @param e
		 */
		private function onNetStatus(e:NetStatusEvent):void {
			Config.addLog("rec\t", e.info.code);
			switch (e.info.code) {
				case "NetConnection.Connect.Success":
					liveBut.enabled = recordBut.enabled = true;
					createNetStream();
					break;
				case "NetConnection.Connect.Failed":
					connectBut.enabled = true;
					liveBut.enabled = recordBut.enabled = false;
					break;
			}
		}
		
		/**
		 * Create NetStream Camera and Microphone
		 */
		private function createNetStream():void {
			if (!ns) {
				ns = new NetStream(nc);
				ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
			
			if (!c) c = Camera.getCamera();
			c.setMode(320, 240, 25);
			c.setQuality(0, 90);
			
			if (!m) m = Microphone.getMicrophone();
			m.rate = 44;
			m.gain = 80;
			m.setUseEchoSuppression(true);
			
			v.attachCamera(c);
		}
		
		/**
		 * Start publish stream live or record
		 * @param type type of stream, live or record
		 */
		private function start(type:String):void {
			var d:Date = new Date();
			var arr:Array = [d.getFullYear(), d.getMonth()+1, d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds()];
			var fn:String = type + "_"+ arr.join("-") + ".flv";
			
			ns.attachCamera(c);
			ns.attachAudio(m);
			ns.publish(fn, type);
			
			liveBut.removeEventListener(MouseEvent.CLICK, onLive);
			recordBut.removeEventListener(MouseEvent.CLICK, onRecord);
			
			if (type == "live") {
				recordBut.enabled = false;
				liveBut.label = "STOP";
				liveBut.addEventListener(MouseEvent.CLICK, onStop);
			} else {
				liveBut.enabled = false;
				recordBut.label = "STOP";
				recordBut.addEventListener(MouseEvent.CLICK, onStop);
			}
			
			Config.setURL(fn);
			Config.addLog("rec name\t", fn);
		}
		private function onStop(e:MouseEvent):void {
			ns.publish();
			ns.attachCamera(null);
			ns.attachAudio(null);
			ns.close();
			
			liveBut.label = "LIVE";
			recordBut.label = "RECORD";
			liveBut.enabled = recordBut.enabled = true;
			
			liveBut.removeEventListener(MouseEvent.CLICK, onStop);
			recordBut.removeEventListener(MouseEvent.CLICK, onStop);
			
			liveBut.addEventListener(MouseEvent.CLICK, onLive);
			recordBut.addEventListener(MouseEvent.CLICK, onRecord);
		}
		
	}
}