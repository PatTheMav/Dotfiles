ifndef INCLUDED_FFMPEG_CONFIG
ifeq (brew,$(PKG_NAME))
INCLUDED_FFMPEG_CONFIG = TRUE

.SUFFIXES :

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

## VARIABLES
ffmpeg-custom_LOCATION := $(BREW_ROOT)/Cellar/ffmpeg-custom
ffmpeg-custom_OPTIONS := --with-webp --with-speex --with-srt --with-dav1d

## TARGETS
.PHONY : ffmpeg
ffmpeg : | $(PKG_CMD) $(ffmpeg-custom_LOCATION)
endif
endif
