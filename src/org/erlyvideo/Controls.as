package org.erlyvideo {
	
	import com.bit101.charts.LineChart;
	import com.bit101.components.ComboBox;
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
	import flash.filters.GlowFilter;
	import flash.utils.setTimeout;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.traits.LoadState;
	
	public class Controls extends Sprite {
		
		private const GLOW:GlowFilter = new GlowFilter(0xFFFFFF, 1, 2, 2, 10, 3);
		private const STAT_LENGTH:int = 20;
		
		private var player:MediaPlayer;
		
		// top
		public var urlInput:Text;
		private var connectBut:PushButton;
		
		// panels
		private var log:TextArea;
		private var controlsBox:HBox;
		private var statWindow:Window;
		private var stat:LineChart;
		private var bitrate:ComboBox;
		private var language:ComboBox;
		
		// bottom
		private var stop:PushButton;
		private var play:PushButton;
		private var pause:PushButton;
		private var time:Label;
		private var bar:HSlider;
		private var volume:Knob;
		
		private var isTimeshift:Boolean;
		private var timeshiftDelta:Number;
		
		public function Controls() {
			init();
		}
		
		private function init():void {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			player = Config.app.player.p;
			createControls();
			createListenerPlayer();
		}
		
		/**
		 * Create controls
		 */
		private function createControls():void {
			// EXMAPLE URLS
			const hb:HBox = new HBox();
			const exLabel:Label = new Label(hb, 0, 1, "EX:");
			const bfms:PushButton = new PushButton(hb, 0, 0, "FMS", onFMSVideo);
			const berl:PushButton = new PushButton(hb, 0, 0, "VIDEO.MP4", onERLVideo);
			const bts:PushButton = new PushButton(hb, 0, 0, "MPEG-TS", onTSVideo);
			bfms.width = berl.width = bts.width = 60;
			
			// URL INPUT FIELD
			const urlLabel:Label = new Label(hb, 0, 1, "URL:");
			urlInput = new Text(hb, 0, -1);
			urlInput.height = bfms.height;
			urlInput.textField.multiline = false;
			urlInput.textField.wordWrap = false;
			urlInput.editable = true;
			urlInput.text = Config.SERVER + "/" + Config.APP + "/" + Config.FILE;
			if (Config.vars.file) {
				Config.app.player.connect(urlInput.text, Config.AUTOSTART);
			}
			
			// CONNECT BUTTON
			connectBut = new PushButton(hb, 0, 0, "CONNECT", onConnect);
			
			// LOG WINDOW
			const logWindow:Window = new Window(null, 5, 30, "LOG");
			logWindow.hasMinimizeButton = true;
			log = new TextArea(logWindow.content);
			log.editable = false;
			log.height = 120;
			logWindow.width = log.width;
			logWindow.height = log.height + 20;
			
			// CONTROLS HBOX
			controlsBox = new HBox();
			controlsBox.enabled = false;
			
			// STOP BUTTON
			stop = new PushButton(controlsBox, 0, 0, "STOP", onStop);
			stop.enabled = false;
			
			// PLAY BUTTON
			play = new PushButton(controlsBox, 0, 0, "PLAY", onPlay);
			pause = new PushButton(controlsBox, 0, 0, "PAUSE", onPause);
			stop.width = play.width = pause.width = 50;
			
			// TIME AND BAR IN VBOX
			const vb2:VBox = new VBox(controlsBox, 0, 2-stop.height);
			vb2.spacing = 0;
			time = new Label(vb2, 0, 0, "00:00 / 00:00");
			bar = new HSlider(vb2);
			bar.minimum = 0;
			bar.maximum = 1;
			bar.tick = .01;
			bar.height = stop.height;
			bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarDown);
			
			// VOLUME
			volume = new Knob(null, 0, 0, "VOLUME", onVolumeChange);
			volume.minimum = 0;
			volume.maximum = 100;
			volume.labelPrecision = 0;
			volume.value = player.volume * volume.maximum;
			
			// BUFFER LENGTH CHART WINDOW
			statWindow = new Window(null, 0, 30, "BUFFER LENGTH CHART");
			statWindow.hasMinimizeButton = true;
			stat = new LineChart(statWindow.content, 30, 10, []);
			stat.minimum = 0;
			stat.maximum = 0;
			stat.labelPrecision = 1;
			stat.autoScale = false;
			stat.showScaleLabels = true;
			statWindow.width = stat.x + stat.width + 10;
			statWindow.height = 4 * stat.y + stat.height;
			statWindow.y = logWindow.y;
			// fill chart empty values
			for (var i:uint=0; i<STAT_LENGTH; ++i) stat.data.push(0);
			
			// Bitrate selection
			bitrate = new ComboBox(null, 0, 0, "Bitrate");
			bitrate.addEventListener(Event.SELECT, onBitrateChange);
			bitrate.y = logWindow.y + statWindow.height + 10;
			bitrate.width = statWindow.width / 2 - 4;
			
			language = new ComboBox(null, 0, 0, "Language");
			language.addEventListener(Event.SELECT, onLanguageChange);
			language.y = logWindow.y + statWindow.height + 10;
			language.width = statWindow.width / 2 - 4;
			
			// FILTERS FOR LABELS, because over black video labels invisible
			volume.filters = exLabel.filters = urlLabel.filters = time.filters = [GLOW];
			
			addChild(hb);
			addChild(controlsBox);
			addChild(volume);
			addChild(logWindow);
			addChild(statWindow);
			addChild(bitrate);
			addChild(language);
			
			stage.addEventListener(Event.RESIZE, onResize);
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
		
		private function onBitrateChange(e:Event):void {
			Config.addLog("change bitrate");
		}
		private function onLanguageChange(e:Event):void {
			Config.addLog("change language");
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
			if (isTimeshift) {
				var newTimeshiftDelta:Number = Math.min(
					// limit timeshift delta, -.1 for not seek to 0
					player.currentTime + timeshiftDelta - .1,
					// try set timeshift delta
					Config.TIMESHIFT * (1-bar.value)
				);
				player.seek(player.currentTime + timeshiftDelta - newTimeshiftDelta);
				addLog("try seek to\t", player.currentTime + timeshiftDelta - newTimeshiftDelta);
				timeshiftDelta = newTimeshiftDelta;
			} else {
				player.seek(player.duration * bar.value);
			}
		}
		private function onVolumeChange(e:Event):void {
			player.volume = volume.value / volume.maximum;
		}
		
		/**
		 * On resize application
		 * @param e
		 */
		private function onResize(e:Event = null):void {
			const w:int = stage.stageWidth;
			const h:int = stage.stageHeight;
			
			urlInput.width = w - urlInput.x - connectBut.width - 10;
			connectBut.x = w - connectBut.width;
			
			statWindow.x = w - statWindow.width - 5;
			language.x = w - language.width - 5;
			bitrate.x = language.x - bitrate.width - 10;
			
			controlsBox.y = h - stop.height;
			volume.x = w - volume.width - 4;
			volume.y = h - volume.height + 4;
			bar.width = w - stop.width - play.width - pause.width - (w-volume.x) - controlsBox.numChildren * controlsBox.spacing;
		}
		
		/**
		 * Create listeners for player
		 */
		private function createListenerPlayer():void {
			player.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange); 
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
			player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onCanPlayChange);
			player.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
			player.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekChange);
			player.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			player.addEventListener(TimeEvent.COMPLETE, onTimeComplete);
		}
		
		private function onLoadStateChange(e:LoadEvent):void {
			if (e.loadState == LoadState.READY) {
				(player.media as MyVideoElement).client.addHandler("onMetaData", onMetaData);
			}
		}
		
		private function onMetaData(info:Object):void {
			if ("bitrates" in info) {
				const items:Array = [];
				const len:uint = info.bitrates.length;
				for (var i:uint = 0; i < len; i++) {
					items.push(int(info.bitrates[i] / 1024) + " kbps");
				}
				bitrate.items = items;
			}
			if ("languages" in info) {
				language.items = info.languages;
			}
		}
		
		private function onStateChange(e:MediaPlayerStateChangeEvent):void {
			addLog("state\t\t", e.state)
			switch (e.state) {
				case MediaPlayerState.READY:
					stop.enabled = false;
					
					// set buffer time
					if (Config.vars.buffer != undefined) {
						player.bufferTime = Number(Config.vars.buffer);
						addLog("bufferTime\t", player.bufferTime);
					}
					
					// reset timeshift
					isTimeshift = false;
					timeshiftDelta = 0;
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
			if (e.newWidth > 0) addLog("video_size\t", e.newWidth, " x ", e.newHeight);
		}
		private function onDurationChange(e:TimeEvent):void {
			// if duration is NaN that mean is timeshift
			isTimeshift = isNaN(e.time);
			if (!isTimeshift) addLog("duration\t", e.time);
		}
		private function onCurrentTimeChange(e:TimeEvent):void {
			isTimeshift = isNaN(player.duration);
			
			if (isTimeshift) {
				// timeshift
				time.text = Config.timerFormat(player.currentTime) + " / " + Config.timerFormat(player.currentTime + timeshiftDelta);
				bar.value = 1 - timeshiftDelta / Config.TIMESHIFT;
			} else {
				// default
				time.text = Config.timerFormat(player.currentTime) + " / " + Config.timerFormat(player.duration);
				bar.value = player.currentTime / player.duration;
			}
			
			// buffer length chart
			stat.data.push(player.bufferLength);
			while (stat.data.length > 20) stat.data.shift();
			var len:uint = stat.data.length;
			var maxValue:Number = Number.NEGATIVE_INFINITY;
			var value:Number;
			for (var i:uint=0; i<len; ++i) {
				value = stat.data[i];
				maxValue = maxValue < value ? value : maxValue;
			}
			stat.maximum = maxValue;
			stat.data = stat.data;
		}
		private function onTimeComplete(e:TimeEvent):void {
			addLog("complete");
		}
		
		/**
		 * Add text in log window
		 * @param args Arguments like trace
		 */
		public function addLog(...args):void {
			log.textField.appendText(args.join("") + "\n");
			log.textField.scrollV = log.textField.maxScrollV;
		}
		
	}
}