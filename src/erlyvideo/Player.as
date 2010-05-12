package erlyvideo {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamingURLResource;
	
	public class Player extends Sprite {
		
		public var p:MediaPlayer;
		
		private var c:MediaContainer;
		private var l:LayoutMetadata;
		private var v:VideoElement;
		private var r:URLResource;
		
		public function Player() {
			createPlayer();
		}
		
		/**
		 * Create player
		 */
		private function createPlayer():void {
			l = new LayoutMetadata();
			l.scaleMode = ScaleMode.LETTERBOX;
			l.snapToPixel = true;
			l.horizontalAlign = HorizontalAlign.CENTER;
			l.verticalAlign = VerticalAlign.MIDDLE;
			
			p = new MediaPlayer();
			p.volume = .3;
			p.autoPlay = false;
			
			c = new MediaContainer(null, l);
			addChild(c);
			
			Config.app.stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Connect to url
		 */
		public function connect(url:String, autoPlay:Boolean=false):void {
			if (url.length == 0) return;
			if (v) c.removeMediaElement(v);
			if (Config.vars.session) {
  			r = new StreamingURLResource(url, null, NaN, NaN, Vector.<Object>([Config.vars.session]));
			} else {
			  r = new StreamingURLResource(url);
			}
			v = new MyVideoElement(r);
			v.smoothing = true;
			p.media = v;
			p.autoPlay = autoPlay;
			c.addMediaElement(v);
		}
		
		/**
		 * On resize
		 * @param e
		 */
		private function onResize(e:Event = null):void {
			var w:int = Config.app.stage.stageWidth;
			var h:int = Config.app.stage.stageHeight;
			
			l.width = w;
			l.height = h;
		}
		
	}
}