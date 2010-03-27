all: bin-release/ErlyvideoPlayer.swf
	
	
bin-release/ErlyvideoPlayer.swf: src/*.as libs/*.swc
	mxmlc -output bin-release/ErlyvideoPlayer.swf -compiler.external-library-path=libs src/ErlyvideoPlayer.as

