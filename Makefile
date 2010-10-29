Sources = src/*.as src/org/erlyvideo/*.as


all: bin-release/ErlyvideoPlayer.swf
	
clean:
	rm -f bin-release/ErlyvideoPlayer.swf
	
bin-release/ErlyvideoPlayer.swf: $(Sources) libs/*.swc
	LC_ALL=C mxmlc -output bin-release/ErlyvideoPlayer.swf -library-path libs -static-link-runtime-shared-libraries -target-player 10.1.0 src/ErlyvideoPlayer.as

