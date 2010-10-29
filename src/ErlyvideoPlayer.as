package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.erlyvideo.Chat;
	import org.erlyvideo.Config;
	import org.erlyvideo.Controls;
	import org.erlyvideo.Player;
	import org.erlyvideo.Record;
	
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
		 * Check stage on exists and width > 0 and height > 0
		 */
		private function checkStage():void {
			if (stage) {
				if (stage.stageWidth > 0 && stage.stageHeight > 0) {
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
			// stage setup
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			
			// context menu setup
			const cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			var cmi:ContextMenuItem;
			cmi = new ContextMenuItem("Erlyvideo multiprotocol streaming server", false, false);
			cm.customItems.push(cmi);
			cmi = new ContextMenuItem("erlyvideo.org");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, getHandlerToURL("http://erlyvideo.org"));
			cm.customItems.push(cmi);
			cmi = new ContextMenuItem("Programming ErlyvideoPlayer", true, false);
			cm.customItems.push(cmi);
			cmi = new ContextMenuItem("kutu.ru");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, getHandlerToURL("http://kutu.ru"));
			cm.customItems.push(cmi);
			contextMenu = cm;
			
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
		
		/**
		 * Get function for ContextMenuItem
		 */
		private function getHandlerToURL(url:String):Function {
			return function(e:ContextMenuEvent):void {
				navigateToURL(new URLRequest(url), "_blank");
			}
		}
		
	}
}