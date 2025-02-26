#!/bin/sh
localDir="/Users/$USER/Pictures/BingWallpaper"
filenameRegex=".*"$(date "+%Y-%m-%d")".*jpg"
log="$localDir/bin/log.log"

if [ ! -d "$localDir" ]; then
    mkdir "$localDir"
fi

findResult=$(find $localDir -regex $filenameRegex)

if [ ! -n "$findResult" ]; then
    baseUrl="cn.bing.com"
    html=$(curl -L $baseUrl)
    echo "${html}" > index.html

    imgurl=$(expr "$(echo "$html" | grep "&amp;rf")" : '.*href=\"\(\/th\?id=OHR\.[A-Za-z]*\_ZH\-CN[0-9]*\_1920x1080\.jpg\).*')
    echo $imgurl

    filename=$(expr "$imgurl" : '.*OHR\.\(.*\)')
    echo $filename
    localpath="$localDir/$(date "+%Y-%m-%d")-$filename"
    curl -o $localpath $baseUrl/$imgurl

    des=$(expr "$(echo "$html" | grep "id=\"sh_cp\" class=\"sc_light\"")" : '.*id=\"sh_cp\".*title=\"\(.*\)\" aria-label=\"主页图片信息\"')

    osascript -e "                              \
        tell application \"System Events\" to   \
            tell every desktop to               \
                set picture to \"$localpath\""
    osascript -e "display notification \"$des\" with title \"BingWallpaper\""
    echo "$(date +"%Y-%m-%d %H:%M:%S") Downloaded $filename" >> $log
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") Exist" >> $log
    exit 0
fi
