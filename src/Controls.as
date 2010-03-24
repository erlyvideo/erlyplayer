package {
	
	import com.bit101.components.HBox;
	import com.bit101.components.HSlider;
	import com.bit101.components.Knob;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	
	public class Controls extends Sprite {
		
		private var player:MediaPlayer;
		
		private var urlInput:Text;
		private var log:TextArea;
		private var controlsBox:HBox;
		private var stop:PushButton;
		private var play:PushButton;
		private var pause:PushButton;
		private var time:Label;
		private var bar:HSlider;
		private var volume:Knob;
		
		public function Controls() {
			player = Config.app.player.p;
			init();
			createListenerPlayer();
		}
		
		/**
		 * Create controls
		 */		
		private function init():void {
			// top
			var hb:HBox = new HBox();
			new Label(hb, 0, 0, "EX:");
			var bfms:PushButton = new PushButton(hb, 0, 0, "FMS", onFMSVideo);
			var berl:PushButton = new PushButton(hb, 0, 0, "VIDEO.MP4", onERLVideo);
			var bts:PushButton = new PushButton(hb, 0, 0, "MPEG-TS", onTSVideo);
			bfms.width = berl.width = bts.width = 60;
			
			// custom url
			new Label(hb, 0, 0, "URL:");
			urlInput = new Text(hb);
			urlInput.height = bfms.height;
			urlInput.textField.multiline = false;
			urlInput.textField.wordWrap = false;
			urlInput.editable = true;
			if (Config.vars.url) {
				urlInput.text = Config.vars.url;
				Config.app.player.connect(urlInput.text);
			}
			var connectBut:PushButton = new PushButton(hb, 0, 0, "CONNECT", onConnect);
			
			// log
			var logWindow:Window = new Window(null, 10, 30, "log");
			logWindow.hasMinimizeButton = true;
			log = new TextArea(logWindow.content);
			log.editable = false;
			log.height = 120;
			logWindow.width = log.width;
			logWindow.height = log.height + 20;
			
			// bottom
			controlsBox = new HBox();
			controlsBox.enabled = false;
			
			stop = new PushButton(controlsBox, 0, 0, "STOP", onStop);
			stop.enabled = false;
			
			play = new PushButton(controlsBox, 0, 0, "PLAY", onPlay);
			pause = new PushButton(controlsBox, 0, 0, "PAUSE", onPause);
			stop.width = play.width = pause.width = 50;
			
			var vb2:VBox = new VBox(controlsBox, 0, 2-stop.height);
			vb2.spacing = 0;
			time = new Label(vb2, 0, 0, "00:00 / 00:00");
			bar = new HSlider(vb2);
			bar.minimum = 0;
			bar.maximum = 1;
			bar.tick = .01;
			bar.height = stop.height;
			bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarDown);
			
			volume = new Knob(null, 0, 0, "volume", onVolumeChange);
			volume.minimum = 0;
			volume.maximum = 100;
			volume.labelPrecision = 0;
			volume.value = player.volume * volume.maximum;
			
			addChild(hb);
			addChild(logWindow);
			addChild(controlsBox);
			addChild(volume);
			
			Config.app.stage.addEventListener(Event.RESIZE, onResize);
			setTimeout(onResize, 100);
		}
		private function onFMSVideo(e:MouseEvent):void {
			changeURL(Config.VIDEO_URL_FMS);
		}
		private function onERLVideo(e:MouseEvent):void {
			changeURL(Config.VIDEO_URL_ERL);
		}
		private function onTSVideo(e:MouseEvent):void {
			changeURL(Config.VIDEO_URL_TS);
		}
		private function changeURL(url:String):void {
			urlInput.text = url;
			Config.app.player.connect(url);
		}
		private function onConnect(e:MouseEvent):void {
			Config.app.player.connect(urlInput.text);
		}
		private function onStop(e:MouseEvent):void {
			player.stop();
			stop.enabled = false;
		}
		private function onPlay(e:MouseEvent):void {
			player.play();
		}
		private function onPause(e:MouseEvent):void {
			player.pause();
		}
		private function onBarDown(e:MouseEvent):void {
			player.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			stage.addEventListener(MouseEvent.MOUSE_UP, onBarUp);
		}
		private function onBarUp(e:MouseEvent):void {
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onBarUp);
			player.seek(player.duration * bar.value);
		}
		private function onVolumeChange(e:Event):void {
			player.volume = volume.value / volume.maximum;
		}
		
		/**
		 * On resize
		 * @param e
		 */		
		private function onResize(e:Event = null):void {
			var w:int = Config.app.stage.stageWidth;
			var h:int = Config.app.stage.stageHeight;
			
			urlInput.width = w - 353;
			
			controlsBox.y = h - stop.height;
			bar.width = w - stop.width - play.width - pause.width - volume.width - (controlsBox.numChildren-1)*controlsBox.spacing;
			volume.x = w - volume.width;
			volume.y = h - volume.height + 4;
		}
		
		/**
		 * Add log in textarea
		 * @param args
		 */		
		private function addLog(...args):void {
			log.text += args.join(" ") + "\n";
			setTimeout(function():void {log.textField.scrollV = log.textField.maxScrollV}, 100);
		}
		
		/**
		 * Create listeners for player
		 */		
		private function createListenerPlayer():void {
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
			player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onCanPlayChange);
			player.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekChange);
			player.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
			player.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			player.addEventListener(TimeEvent.COMPLETE, onTimeComplete);
		}
		private function onStateChange(e:MediaPlayerStateChangeEvent):void {
			addLog("state\t\t", e.state)
			switch (e.state) {
				case MediaPlayerState.READY:
					stop.enabled = false;
				case MediaPlayerState.PAUSED:
					play.enabled = true;
					pause.enabled = false;
					break;
				case MediaPlayerState.PLAYING:
					play.enabled = false;
					pause.enabled = true;
					stop.enabled = true;
					break;
			}
		}
		private function onCanPlayChange(e:MediaPlayerCapabilityChangeEvent):void {
			controlsBox.enabled = e.enabled;
		}
		private function onSeekChange(e:SeekEvent):void {
			if (e.seeking) addLog("seeking to\t", e.time);
		}
		private function onMediaSizeChange(e:DisplayObjectEvent):void {
			if (e.newWidth > 0) addLog("video_size\t", e.newWidth, e.newHeight);
		}
		private function onDurationChange(e:TimeEvent):void {
			addLog("duration\t", e.time);
		}
		private function onCurrentTimeChange(e:TimeEvent):void {
			if (isNaN(player.duration)) {
				bar.enabled = false;
			} else {
				bar.enabled = true;
				bar.value = player.currentTime / player.duration;
			}
			time.text = Config.timerFormat(player.currentTime) + " / " + Config.timerFormat(player.duration);
		}
		private function onTimeComplete(e:TimeEvent):void {
			addLog("complete");
		}
		
	}
}