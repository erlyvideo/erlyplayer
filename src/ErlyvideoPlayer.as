package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	[SWF(width=800, height=500, backgroundColor=0xFFFFFF, frameRate=25)]
	
	public class ErlyvideoPlayer extends Sprite {
		
		public var player:Player;
		public var controls:Controls;
		
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
			
			player = new Player();
			controls = new Controls();
			
			addChild(player);
			addChild(controls);
		}
		
	}
}