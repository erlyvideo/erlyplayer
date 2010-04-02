package {
	
	import flash.net.NetStream;
	
	import org.osmf.net.NetStreamSeekTrait;
	import org.osmf.net.NetStreamTimeTrait;
	
	public class MyNetStreamSeekTrait extends NetStreamSeekTrait {
		
		public function MyNetStreamSeekTrait(timeTrait:NetStreamTimeTrait, stream:NetStream) {
			super(timeTrait, stream);
		}
		
		override public function canSeekTo(time:Number):Boolean {
			return timeTrait ?	 (
					isNaN(time) == false
					&& 	time >= 0
					&&	( isNaN(timeTrait.duration) || (time <= timeTrait.duration || time <= timeTrait.currentTime) )
				)
				: 	false;
		}
		
	}
}