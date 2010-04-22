package {
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamTimeTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class MyVideoElement extends VideoElement {
		
		private var seekTrait:MyNetStreamSeekTrait;
		
		public function MyVideoElement(resource:MediaResourceBase=null, loader:NetLoader=null) {
			super(resource, loader);
			
			addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
		}
		
		private function onTraitAdd(e:MediaElementEvent):void {
			if (hasTrait(MediaTraitType.SEEK) && !seekTrait) {
				const loadTrait:NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				const timeTrait:NetStreamTimeTrait = getTrait(MediaTraitType.TIME) as NetStreamTimeTrait;
				
				seekTrait = new MyNetStreamSeekTrait(timeTrait, loadTrait, loadTrait.netStream);
				
				removeTrait(MediaTraitType.SEEK);
				addTrait(MediaTraitType.SEEK, seekTrait);
				
				removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			}
		}
		
	}
}