Sources = src/*.as


all: bin-release/ErlyvideoPlayer.swf
	
clean:
	rm -f bin-release/ErlyvideoPlayer.swf
	
bin-release/ErlyvideoPlayer.swf: $(Sources) libs/*.swc
	mxmlc -output bin-release/ErlyvideoPlayer.swf -include-libraries libs/MinimalComps_0_9_3.swc -include-libraries libs/OSMF.swc -static-link-runtime-shared-libraries=true src/ErlyvideoPlayer.as

