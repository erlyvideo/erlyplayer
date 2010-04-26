package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import erlyvideo.Chat;
	import erlyvideo.Player;
	import erlyvideo.Config;
	import erlyvideo.Controls;
	import erlyvideo.MyNetStreamSeekTrait;
	import erlyvideo.MyVideoElement;
	import erlyvideo.Player;
	import erlyvideo.Record;
	
	[SWF(width=800, height=500, backgroundColor=0xFFFFFF, frameRate=25)]
	
	public class ErlyvideoPlayer extends Sprite {
		
		public var player:Player;
		public var controls:Controls;
		public var record:Record;
		public var chat:Chat;
		
		public function ErlyvideoPlayer() {
			checkStage();
		}
		
		/**
		 * Check stage on exists and width > 0
		 */
		private function checkStage():void {
			if (stage) {
				if (stage.stageWidth > 0) {
					init();
					return;
				}
				addEventListener(Event.ENTER_FRAME, onCheckStage);
			} else {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			checkStage();
		}
		private function onCheckStage():void {
			removeEventListener(Event.ENTER_FRAME, onCheckStage);
			checkStage();
		}
		
		/**
		 * Init application
		 */
		private function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			
			Config.app = this;
			Config.vars = loaderInfo.parameters;
			
			if (Config.vars.server) Config.SERVER = Config.vars.server;
			if (Config.vars.app) Config.APP = Config.vars.app;
			if (Config.vars.file) Config.FILE = Config.vars.file;
			if (Config.vars.session) Config.SESSION = Config.vars.session;
			if (Config.vars.autostart == "true") Config.AUTOSTART = true;
			
			player = new Player();
			controls = new Controls();
			record = new Record();
			chat = new Chat();
			
			addChild(player);
			addChild(controls);
			addChild(record);
			addChild(chat);
		}
		
	}
}