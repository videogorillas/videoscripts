#!/bin/bash
#
# http://VideoGorillas.com
# Kudos
#  * http://hexeract.wordpress.com/2009/04/12/how-to-compile-ffmpegmplayer-for-macosx/
#  * http://hunterford.me/compiling-ffmpeg-on-mac-os-x/
#  * http://www.haykranen.nl/2007/11/21/howto-install-and-use-ffmpeg-on-mac-os-x-leopard/
#



unpack () {
    if [ -f $1 ] ; then
        case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       rar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.tbz2)      tar xjf $1      ;;
             *.tgz)       tar xzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via unpack()" ;;
        esac
    else
        echo "'$1' is not a valid archive file"
    fi
}

set -ue

DARWIN_MAJOR=`sysctl -n kern.osrelease | cut -d . -f 1`
OSX_MAJOR=$(($DARWIN_MAJOR - 4))
OSX_MINOR=`sysctl -n kern.osrelease | cut -d . -f 2`
XCODE_MAJOR=`/Developer/usr/bin/xcodebuild -version | awk '/Xcode/ {print $2}' | cut -d . -f 1`
XCODE_MINOR=`/Developer/usr/bin/xcodebuild -version | awk '/Xcode/ {print $2}' | cut -d . -f 2`


VOLNAME=VGRamdisk
PRODUCT="VGCoderKit.dmg"
DISK_ID=$(hdid -nomount ram://2097152)
newfs_hfs -v ${VOLNAME} ${DISK_ID}
diskutil mount ${DISK_ID}



# Create some shortcuts
export TARGET="/Volumes/${VOLNAME}"

export SOURCES=$(mktemp -d ${TARGET}/sources)
export CMPL="/Volumes/${VOLNAME}/compile"
export PATH=${TARGET}/bin:$PATH
export THREADS=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Cores/ { print $NF }')
mkdir ${CMPL}

cd ${SOURCES}


# Download the necessary sources.
#echo "Downloading faad2-2.7"
#curl -#LO http://downloads.sourceforge.net/faac/faad2-2.7.tar.gz
echo "Downloading faac-1.28"
curl -#LO http://downloads.sourceforge.net/project/faac/faac-src/faac-1.28/faac-1.28.tar.gz
echo "Downloading lame-3.99"
curl -#LO http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.tar.gz
echo "Downloading libogg-1.3.0"
curl -#LO http://downloads.xiph.org/releases/ogg/libogg-1.3.0.tar.gz
#curl -#LO http://pkg-config.freedesktop.org/releases/pkg-config-0.25.tar.gz
echo "Downloading libvorbis-1.3.3"
curl -#LO http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.gz
echo "Downloading libtheora-1.1.1"
curl -#LO http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
echo "Downloading gsm-1.0.13"
#curl -#LO http://www.quut.com/gsm/gsm-1.0.13.tar.gz
# alternatively gsm could be obtained from:
curl -#LO http://www.imagemagick.org/download/delegates/ffmpeg/gsm-1.0.13.tar.bz2
echo "Downloading yasm-1.1.0"
curl -#LO http://www.tortall.net/projects/yasm/releases/yasm-1.1.0.tar.gz
echo "Downloading libvpx-0.9.7"
curl -#LO http://webm.googlecode.com/files/libvpx-v0.9.7-p1.tar.bz2
echo "Downloading latest_stable_x264"
curl -#LO http://download.videolan.org/pub/videolan/x264/snapshots/last_stable_x264.tar.bz2
echo "Downloading amrwb-10.0.0.0"
curl -#LO http://ftp.penguin.cz/pub/users/utx/amr/amrwb-10.0.0.0.tar.bz2
echo "Downloading amrnb-10.0.0.0"
curl -#LO http://ftp.penguin.cz/pub/users/utx/amr/amrnb-10.0.0.0.tar.bz2
echo "Downloading speex-1.2rc1"
curl -#LO http://downloads.us.xiph.org/releases/speex/speex-1.2rc1.tar.gz
echo "Downloading flac-1.2.1"
curl -#LO http://downloads.sourceforge.net/flac/flac-1.2.1.tar.gz
echo "Downloading vo-aacenc-0.1.1"
curl -#LO http://sourceforge.net/projects/opencore-amr/files/vo-aacenc/vo-aacenc-0.1.1.tar.gz
echo "Downloading vo-amrwbenc-0.1.1"
curl -#LO http://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/vo-amrwbenc-0.1.1.tar.gz
echo "Downloading opencore-amr-0.1.2"
curl -#LO http://sourceforge.net/projects/opencore-amr/files/opencore-amr/0.1.2/opencore-amr-0.1.2.tar.gz
echo "Downloading xvidcore-1.3.2"
curl -#LO http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
echo "Downloading zlib-1.2.5"
curl -#LO http://zlib.net/zlib-1.2.6.tar.gz
echo "Downloading bzip2-1.0.6"
curl -#LO http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
echo "Downloading libxavs"
svn co https://xavs.svn.sourceforge.net/svnroot/xavs xavs
echo "Downloading libvpx"
git clone http://git.chromium.org/webm/libvpx.git
echo "Downloading ffmpeg"
git clone git://git.videolan.org/ffmpeg.git
echo "Downloading mplayer"
svn checkout svn://svn.mplayerhq.hu/mplayer/trunk mplayer
#echo "Downloading libav"
#git clone git://git.libav.org/libav.git
# curl -#LG -d "p=ffmpeg.git;a=snapshot;h=HEAD;sf=tgz" -o ffmpeg.tar.gz http://git.videolan.org/
# curl -#LO http://ffmpeg.org/releases/ffmpeg-0.8.5.tar.bz2

echo "Unpacking files..."

cd ${CMPL}
for file in `ls ${SOURCES}/*.tar.*`; do
    echo "${file}..."
    unpack $file
    rm $file
done
cp -r ${SOURCES}/xavs ${CMPL}/xavs && rm -fr ${SOURCES}/xavs
cp -r ${SOURCES}/libvpx ${CMPL}/libvpx && rm -fr ${SOURCES}/libvpx
cp -r ${SOURCES}/ffmpeg ${CMPL}/ffmpeg && rm -fr ${SOURCES}/ffmpeg
cp -r ${SOURCES}/mplayer ${CMPL}/mplayer && rm -fr ${SOURCES}/mplayer

echo "Building vorbis..."
cd ${CMPL}/libvorbis-*
CC=gcc ./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --enable-static --disable-shared --build=x86_64
make -j $THREADS && make install

echo "Building xavs..."
cd ${CMPL}/xavs/trunk
CC=gcc ./configure --prefix=${TARGET} --disable-asm
make -j $THREADS  && make install

if [[ $XCODE_MAJOR -ge 4 && $XCODE_MINOR -ge 1 ]]; then
   export CC=clang
   export cc=clang
fi

echo "Building yasm..."
cd ${CMPL}/yasm-*
./configure --prefix=${TARGET}
make -j $THREADS && make install

echo "Building lame..."
cd ${CMPL}/lame-*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

#echo "Building faad..."
#cd ${CMPL}/faad2-*
#./configure --prefix=${TARGET} --disable-shared --enable-static
#make -j $THREADS && make install

echo "Building faac..."
cd ${CMPL}/faac-*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

echo "Building xvidcore.. (and removing the dynamic library)..."
cd ${CMPL}/xvidcore*
cd build/generic
./configure --prefix=${TARGET}
make -j $THREADS && make install
echo "Checking for ${TARGET}/lib/libxvidcore.4.dylib"
if [ -e ${TARGET}/lib/libxvidcore.4.dylib ]; then
    rm ${TARGET}/lib/libxvidcore.4.dylib;
fi;

echo "Building x264..."
cd ${CMPL}/x264*stable
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install && make install-lib-static

echo "Building ogg..."
cd ${CMPL}/libogg-*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

echo "Building theora..."
cd ${CMPL}/libtheora-*
./configure --prefix=${TARGET} --disable-asm --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --with-vorbis-libraries=${TARGET}/lib --with-vorbis-includes=${TARGET}/include/ --enable-static --disable-shared
make -j $THREADS && make install

echo "Building gsm..."
cd ${CMPL}/gsm-*
mkdir -p ${TARGET}/man/man3
mkdir -p ${TARGET}/man/man1
perl -p -i -e  "s#^INSTALL_ROOT.*#INSTALL_ROOT = $TARGET#g"  Makefile
perl -p -i -e  "s#_ROOT\)/inc#_ROOT\)/include#g"  Makefile
make -j $THREADS && make install

echo "Building amrwb (downloads additional sources)..."
cd ${CMPL}/amrwb-*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

echo "Building amrnb (downloads additional sources)..."
cd ${CMPL}/amrnb-*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS && make install

echo "Building speex.."
cd ${CMPL}/speex-*
./configure --prefix=${TARGET} --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --enable-static --disable-shared
make -j $THREADS && make install

echo "Building flac..."
cd ${CMPL}/flac-*
./configure --prefix=${TARGET} --disable-asm-optimizations --disable-xmms-plugin --with-ogg-libraries=${TARGET}/lib --with-ogg-includes=${TARGET}/include/ --enable-static --disable-shared
make -j $THREADS && make install



echo "Building vo-aaenc..."
cd ${CMPL}/vo-aacenc-*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS  && make install

echo "Building vo-amrwbenc..."
cd ${CMPL}/vo-amrwbenc-*
./configure --prefix=${TARGET} --disable-shared --enable-static
make -j $THREADS  && make install

echo "Building opencore-amr..."
cd ${CMPL}/opencore-amr-*
./configure --prefix=${TARGET} --enable-static --disable-shared
make -j $THREADS && make install

echo "Building libvpx..."
cd ${CMPL}/libvpx
./configure --prefix=${TARGET} --as=yasm --disable-shared --enable-static
make -j $THREADS && make install

echo "Building zlib..."
cd ${CMPL}/zlib-*
./configure --prefix=${TARGET}
make -j $THREADS && make install
if [ -e ${TARGET}/lib/libz*dylib ]; then
    rm ${TARGET}/lib/libz*dylib
fi

echo "Building bzip2..."
#view sourceprint?
cd ${CMPL}/bzip2-*
make && make install PREFIX=${TARGET}

if [ -e /Developer-old ]; then
  export CC=/Developer-old/usr/bin/gcc-4.2
  export CXX=/Developer-old/usr/bin/g++-4.2
fi

echo "Building ffmpeg"
cd ${CMPL}/ffmpeg
export LDFLAGS="-L${TARGET}/lib ${CFLAGS:-}"
export  CFLAGS="-I${TARGET}/include ${LDFLAGS}"
./configure --prefix=${TARGET} --extra-cflags="-I${TARGET}/include" --extra-ldflags="-L${TARGET}/lib" --cc=clang --as=yasm --extra-version=snowy --disable-shared --enable-static --disable-ffplay --disable-ffserver --enable-gpl --enable-pthreads --enable-postproc --enable-gray --enable-libfaac --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-libspeex --enable-bzlib --enable-zlib --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libxavs --enable-nonfree --enable-version3 --enable-libvo-aacenc --enable-libvo-amrwbenc --enable-libvpx
# --enable-libfaad
make -j $THREADS && make install


echo "Building MPlayer..."
export LDFLAGS=""
export  CFLAGS=""
cd ${CMPL}/mplayer
mv ${CMPL}/ffmpeg/ ./
./configure --prefix="${TARGET}" --extra-cflags="-I${TARGET}/include" --extra-ldflags="-L${TARGET}/lib" --cc=clang  && make -j ${THREADS} && make install


cd ${TARGET} && rm -rf include
cd ${TARGET} && rm -rf lib
cd ${TARGET} && rm -rf compile
rm -rf ${SOURCES}

DISK_IMAGE=$HOME/Downloads/$PRODUCT
if [ -e "${DISK_IMAGE}" ]; then
    echo "Removing the existing image '${DISK_IMAGE}'";
    rm -f ${DISK_IMAGE};
fi
hdiutil create -format UDBZ -volname $PRODUCT -srcfolder ${TARGET} ${DISK_IMAGE}

cd ${HOME}

diskutil unmount ${TARGET}

