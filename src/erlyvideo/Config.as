package erlyvideo {
	
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
		 * Parameters by default
		 */
		public static var SERVER:String = "rtmp://localhost";
		public static var APP:String = "rtmp";
		public static var FILE:String = "video.mp4";
		public static var SESSION:String = "";
		public static var AUTOSTART:Boolean = false;
		public static var TIMESHIFT:Number = 60;
		
		/**
		 * Local settings for player
		 */
//		public static const so:SharedObject = SharedObject.getLocal("ErlyvideoPlayer");
//		public static var SHOW_LOG:Boolean = so.data.showLog;
//		public static var SHOW_STAT:Boolean = so.data.showStat;
		
		/**
		 * Examples urls for testing
		 */
		public static const VIDEO_URL_FMS:String = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";
		public static const VIDEO_URL_ERL:String = "rtmp://erlyvideo.org/rtmp/video.mp4";
		public static const VIDEO_URL_TS:String = "rtmp://erlyvideo.org/rtmp/video.ts";
		
		/**
		 * Formatting time from 100 to 01:40
		 * @param time Time in seconds
		 * @return Formatted time
		 */
		public static function timerFormat(time:Number):String {
			if (isNaN(time)) return "00:00";
			var sign:Boolean = time >= 0;
			if (!sign) time *= -1;		// Math.abs
			var min:Number = int(time/60);
			var sec:Number = int(time - min*60);
			return (sign ? "" : "-") + (min<10 ? "0"+min : min) + ":" + (sec<10 ? "0"+sec : sec);
		}
		
		/**
		 * Set url in URL field
		 * @param url
		 */
		public static function setURL(url:String):void {
			app.controls.urlInput.text = "rtmp://localhost/rtmp/" + url;
		}
		
		/**
		 * Add message in LOG window
		 * @param args parameters for add
		 */
		public static function addLog(...args):void {
			app.controls.addLog.apply(null, args);
		}
		
	}
}