package {
	
	public class Config {
		
		/**
		 * link to main application
		 */
		public static var app:ErlyvideoPlayer;
		
		/**
		 * flashvars
		 */
		public static var vars:Object;
		
		/**
		 * Examples urls for testing
		 */		
		public static const VIDEO_URL_FMS:String = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";
		public static const VIDEO_URL_ERL:String = "rtmp://erlyvideo.org/rtmp/video.mp4";
		public static const VIDEO_URL_TS:String = "rtmp://erlyvideo.org/rtmp/video.ts";
		
		public static function timerFormat(time:Number):String {
			if (isNaN(time)) return "00:00";
			var min:Number = int(time/60);
			var sec:Number = int(time - min*60);
			return (min<10 ? "0"+min : min) + ":" + (sec<10 ? "0"+sec : sec);
		}
		
	}
}