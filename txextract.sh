#!/bin/sh
# Tech Crunch Japan 作業用スクリプト
# 原文 URL を指定すると翻訳対象の .html を抽出し、同時に word 数をカウント
# Eye Catch 画像が指定されている場合にはそれも同時にダウンロード
#RUBY=ruby
RUBY=/usr/bin/ruby
URL=$1
BASE=`basename $1`
mkdir ${BASE}
HTML=${BASE}.html
TEXT=${BASE}.txt
NAME=sako
# BEGINPAT='/<div class="article-content">/'
# ENDPAT='/			<\/div>/'
BEGINPAT='/<div id="root">/'
ENDPAT='/<\/div><!--end #root-->/'
curl -s ${URL} | sed -n -e "${BEGINPAT},${ENDPAT}p" | sed -e "${ENDPAT}i\\
［<a target=\"_blank\" href=\"${URL}\">原文へ</a>］<br>\
（翻訳：${NAME}）\
" > ${BASE}/${HTML}
#
if ! test -s ${BASE}/${HTML}
then
    echo "No contents found in ${URL}. Bye."
    rm ${BASE}/${HTML}
    rmdir ${BASE}
    exit
fi
${RUBY} -e "
require 'open-uri'
require 'rubygems'
require 'nokogiri'

doc = Nokogiri::HTML(\$stdin.read)
doc.css('script, link').each { |node| node.remove }
puts doc.css('body').text.squeeze(\" \n\")
" < ${BASE}/${HTML} | sed '$d' > ${BASE}/${TEXT}
#
echo ".html and .txt files generated."
echo "\"${TEXT}\" contains `wc -w < ${BASE}/${TEXT}` words."
#
# download the eye-catch image (if included).
#
IMGURL=`${RUBY} -e '
require "open-uri"
require "rubygems"
require "nokogiri"

doc = Nokogiri::HTML($stdin.read)
if doc.xpath("//img").length > 0 then
  imgURL = doc.xpath("//img").first["src"]
  puts imgURL
else
  puts ""
end
' < ${BASE}/${HTML}`
if test -n "${IMGURL}"
then
    IMG=`basename "${IMGURL}" | sed 's/?w=[0-9]*$//'`
    curl -s ${IMGURL} > ${BASE}/${IMG}
    echo "$IMG : downloaded."
else
    echo "No eye-catch image."
fi
