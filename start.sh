#!/bin/bash

#-----------------------------------------------------------------------------
#----------------------------1、获取输入参数-------------------------
#-----------------------------------------------------------------------------
# 获取www源地址 目标地址
srcDir=$1
echo "www目录地址"
# 获取p12证书路径
cer_path=$2
echo "p12证书路径：${cer_path}"
# 获取mobileprovision路径
mobileprovision_file=$3
echo "描述文件地址："$mobileprovision_file
# 钥匙串密码
keychain_pass=$4
echo "钥匙串密码："$keychain_pass
# 钥匙串名称
keychain_name=$5
echo "钥匙串名称："$keychain_name
# p12证书密码
p12_pass=$6
echo "p12证书密码："$p12_pass
# 应用ID
BundleID=$7
echo "包名："$BundleID
# 应用名称{拼音}
projectName=$8
echo "应用程序名称{拼音}："$projectName
# 版本
bundleVersion=$9
echo "应用版本："$bundleVersion
#下载地址
packageUrl=${10}
echo "ipa包地址："$packageUrl
#应用名称
displayAppName=${11}
echo "应用展示名称："$displayAppName
#打包日期
packDate=${12}
echo "打包日期："$packDate

#---------------------------------插件--------------------------------------
#插件路径
pluginPath=${13}
echo "插件的路径是："$pluginPath
#---------------------------------Icon----------------------------------------
appIconPath=${14}
echo "AppIcon的路径是："$appIconPath
#-------------------------------LanchImage----------------------------------
lanchImagePath=${15}
echo "加载页的图片路径是："$lanchImagePath
#-------------------------------需要修改的变量----------------------------------
TemplateName=${16} 	#模板工程名
SCHEME_NAME=${17} 	#scheme名称
OwnerName=${18}		#mac计算机名称

#-----------------------------------------------------------------------------
#--------------------------------2、转移www目录----------------------------
#-----------------------------------------------------------------------------

#----------------创建工程副本--------------
cd ..
# 工程副本地址
baseProjectTempPath=`pwd`
# 如果存在工程副本，先删除
if [ -d ${projectName}Temp ]
then
	rm -rf ${projectName}Temp
fi
# 如果存在工程Build文件，先删除
if [ -d ${projectName}Build ]
then
	rm -rf ${projectName}Build
fi
# 创建Temp文件
cp -r ${TemplateName} ${projectName}Temp 
# 如果ios目录存在build文件，删除
if [ -d ${projectName}Temp/platforms/ios/build ];
then
	rm -rf ${projectName}Temp/platforms/ios/build
fi
# 切换到工程副本文件
cd ${projectName}Temp

#----------------生成Icon图标(如果存在)----------------
destIconPath=`pwd`/platforms/ios/${SCHEME_NAME}/Images.xcassets/AppIcon.appiconset
echo "目标地址："$destIconPath
if [ "$appIconPath" != "" ]; then
	echo "开始生成图标"
	convert ${appIconPath} -resize 40x40 	$destIconPath/icon-40.png
	convert ${appIconPath} -resize 80x80 	$destIconPath/icon-40@2x.png
	convert ${appIconPath} -resize 50x50 	$destIconPath/icon-50.png
	convert ${appIconPath} -resize 100x100 	$destIconPath/icon-50@2x.png
	convert ${appIconPath} -resize 120x120 	$destIconPath/icon-60@2x.png
	convert ${appIconPath} -resize 180x180 	$destIconPath/icon-60@3x.png
	convert ${appIconPath} -resize 72x72 	$destIconPath/icon-72.png
	convert ${appIconPath} -resize 144x144 	$destIconPath/icon-72@2x.png
	convert ${appIconPath} -resize 76x76 	$destIconPath/icon-76.png
	convert ${appIconPath} -resize 152x152 	$destIconPath/icon-76@2x.png
	convert ${appIconPath} -resize 167x167 	$destIconPath/icon-83.5@2x.png
	convert ${appIconPath} -resize 29x29 	$destIconPath/icon-small.png
	convert ${appIconPath} -resize 58x58 	$destIconPath/icon-small@2x.png
	convert ${appIconPath} -resize 87x87 	$destIconPath/icon-small@3x.png
	convert ${appIconPath} -resize 57x57 	$destIconPath/icon.png
	convert ${appIconPath} -resize 114x114 	$destIconPath/icon@2x.png
else
	echo "没有图标，使用默认的"
fi

#----------------生成Splash图标图标(如果存在)----------------
destIconPath=`pwd`/platforms/ios/${SCHEME_NAME}/Images.xcassets/LaunchImage.launchimage
if [ "$lanchImagePath" != "" ]; then
	echo "开始生成加载页图片"
	convert ${lanchImagePath} -resize 640x1136!  -quality 20 	$destIconPath/Default-568h@2x~iphone.png
	convert ${lanchImagePath} -resize 750x1334!  -quality 20	$destIconPath/Default-667h.png
	convert ${lanchImagePath} -resize 1242x2208! -quality 20	$destIconPath/Default-736h.png
	convert ${lanchImagePath} -resize 2208x1242! -quality 20 	$destIconPath/Default-Landscape-736h.png
	convert ${lanchImagePath} -resize 2048x1536! -quality 20 	$destIconPath/Default-Landscape@2x~ipad.png
	convert ${lanchImagePath} -resize 1024x768!  -quality 20	$destIconPath/Default-Landscape~ipad.png
	convert ${lanchImagePath} -resize 1536x2048! -quality 20	$destIconPath/Default-Portrait@2x~ipad.png
	convert ${lanchImagePath} -resize 768x1024!  -quality 20	$destIconPath/Default-Portrait~ipad.png
	convert ${lanchImagePath} -resize 640x960! 	 -quality 20	$destIconPath/Default@2x~iphone.png
	convert ${lanchImagePath} -resize 320x480! 	 -quality 20 	$destIconPath/Default~iphone.png
else
	echo "没有加载页图片，使用默认的"
fi

#--------------------------------安装插件(如果存在)-------------------------
if [ "$pluginPath" != "" ]; then
	echo "开始安装插件"
	cordova plugin add $pluginPath
else
	echo "没有插件"
fi

# exit 0

#----------------------------------转移www目录--------------------------------
# 获取脚本父路径
basepath=$(cd `dirname $0`; pwd)
# www要拷贝到工程的地址
destDir=$basepath/platforms/ios
echo "原地址=${srcDir} && 目的地址=${destDir}"
cd platforms/ios
# 判断工程下面是否存在www目录
if [ -d ${destDir}/www ]; then
	rm -rf www
fi
# 开始拷贝www文件
cp -r $srcDir $destDir
# 拷贝Cordova平台文件到工程
for file in `ls ./platform_www`
do
	if [ -d $destDir/platform_www/$file ];
	then
		cp -r $destDir/platform_www/$file $destDir/www
	else
		cp $destDir/platform_www/$file $destDir/www
	fi
done
echo "拷贝www工程完成"

#-----------------------------------------------------------------------------
#-------------------------------------3、安装证书和描述文件-------------------------------
#-----------------------------------------------------------------------------
# 删除钥匙串
keychainIsExit=`cd /Users/${OwnerName}/Library/Keychains/ && ls | grep ${keychain_name}`
if [ ${#keychainIsExit} != 0 ]; 
then
	security delete-keychain "${keychain_name}"
	echo "删除钥匙串成功"
else
	echo "没有${keychain_name}钥匙串"
fi

#创建钥匙串
security create-keychain -p "${keychain_pass}" "${keychain_name}" 
echo "钥匙串创建成功"
#解锁钥匙串
security unlock-keychain  -p "${keychain_pass}" "${keychain_name}"
#导入证书
security import "${cer_path}"  -k "${keychain_name}" -P "${p12_pass}" -A
# security import "${cer_path}"  -k "${keychain_name}" -P "${p12_pass}" -A -T /usr/bin/codesign
#上锁钥匙串
security lock-keychain "${keychain_name}"
#------------------------------------------------------------------------------
security unlock-keychain -p "123456" /Users/anyware/Library/Keychains/login.keychain
security import "${cer_path}" -k /Users/anyware/Library/Keychains/login.keychain -P "123456" -A -T /usr/bin/codesign


# 拷贝mobileprovision到系统库
mobileprovision_uuid=`grep UUID -A1 -a ${mobileprovision_file} | grep -o "[-A-Za-z0-9]\{36\}"`
echo "UUID:${mobileprovision_uuid}"
cp ${mobileprovision_file} ~/Library/MobileDevice/Provisioning\ Profiles/${mobileprovision_uuid}.mobileprovision
echo "证书导入完毕"

#-------------------------------------------------------------------------------
#-------------------------------------4、编译打包---------------------------------
#-------------------------------------------------------------------------------
# 判断证书的类型
isDebugCert=`security find-identity -v codesigning ${keychain_name} | grep "Developer"`
if [ ${#isDebugCert} != 0 ]; then
	ID=2
else
	ID=1
fi

# appstore
if [ "${ID}" = "1" ];then
	mode="Release"
# Debug
elif [ "${ID}" = "2" ]; then
	mode="Debug"
else
	echo "打包模式选择错误"
	exit 1
fi

echo "打包模式："$mode
echo "mobileprovition文件名："$mobileprovision_uuid

# 获取证书的名称
CODE_SIGN_IDENTITY_NAME=`security find-identity -v -p codesigning "${keychain_name}"`
sub="\ "
CODE_SIGN_IDENTITY_NAME=${CODE_SIGN_IDENTITY_NAME#*$sub}
CODE_SIGN_IDENTITY_NAME=${CODE_SIGN_IDENTITY_NAME#*$sub}
sub="\""
CODE_SIGN_IDENTITY_NAME=${CODE_SIGN_IDENTITY_NAME#*$sub}
CODE_SIGN_IDENTITY_NAME=${CODE_SIGN_IDENTITY_NAME%%$sub*}
echo "证书名称："$CODE_SIGN_IDENTITY_NAME

# xcodebuild build产生文件地址
AppPath="build/${mode}/`date "+%Y-%m-%d"`"
# ipa文件地址
IPAPath=`pwd`/build/${projectName}_${packDate}.ipa

# 编译xcarchive
xcodebuild \
-project $SCHEME_NAME.xcodeproj \
-scheme $SCHEME_NAME \
-configuration $mode \
-derivedDataPath ${AppPath} \
clean \
build \
CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY_NAME}" \
PROVISIONING_PROFILE="${mobileprovision_uuid}" \
PRODUCT_BUNDLE_IDENTIFIER="${BundleID}"

if [ -e ${AppPath} ];
then
	echo "-----------------------------------------------"
	echo "-------------xcodebuild success----------------"
	echo "-----------------------------------------------"
else
	echo "-----------------------------------------------"
	echo "--------------xcodebuild error-----------------"
	echo "-----------------------------------------------"
fi

#exit 1

# xcrun
xcrun \
-sdk iphoneos PackageApplication \
-v ${AppPath}/Build/Products/$mode-iphoneos/$SCHEME_NAME.app \
-o ${IPAPath}

if [ -e ${IPAPath} ];
then
	echo "-----------------------------------------------"
	echo "---------------------编译成功-------------------"
	echo "-----------------------------------------------"
else
	echo "-----------------------------------------------"
	echo "---------------------编译失败-------------------"
	echo "-----------------------------------------------"
fi

#-----------------------------------------------------------------------------
#---------------------------------5、生成plist文件------------------------------
#-----------------------------------------------------------------------------
# source ./plist.sh
plistPath=${baseProjectTempPath}/${projectName}Temp/platforms/ios/build/${projectName}_${packDate}.plist

cat << EOF  > $plistPath
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>items</key>
<array>
<dict>
<key>assets</key>
<array>
<dict>
<key>kind</key>
<string>software-package</string>
<key>url</key>
<string>${packageUrl}</string>
</dict>
</array>
<key>metadata</key>
<dict>
<key>bundle-identifier</key>
<string>${BundleID}</string>
<key>bundle-version</key>
<string>${bundleVersion}</string>
<key>kind</key>
<string>software</string>
<key>subtitle</key>
<string>ProductName</string>
<key>title</key>
<string>${projectName}</string> 
</dict>
</dict>
</array>
</dict>
</plist>

EOF

#-----------------------------------------------------------------------------
#--------------------------------6、转移build目录--------------------------------
#-----------------------------------------------------------------------------
cd ${baseProjectTempPath}
mkdir ${projectName}Build 
# 转移产生的plist文件和ipa包
cp $plistPath ${baseProjectTempPath}/${projectName}Build
cp $IPAPath ${baseProjectTempPath}/${projectName}Build
# 删除工程副本文件
rm -rf ${baseProjectTempPath}/${projectName}Temp