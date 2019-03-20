#!/bin/sh

#  PrepareXCodeProj.sh
#  
#
#  Created by Mannie Tagarira on 3/20/19.
#  

swift build
swift package generate-xcodeproj
open ./EventStreamer.xcodeproj
