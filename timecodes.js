const { spawn } = require('child_process');
let url = '/Volumes/storage-1/clients/sdi/PKG - RE_ next step - timecode recognition/GTS_Proxy_Source_examples/BITC_examples/prealoneals_ef011_tpm_w3519355_fprhq_v1080p25_a16x9_178_le.mpg';
const child = spawn('ffprobe', ["-print_format", "json", "-show_format", "-show_streams", url]);

function isDropFrameString(tc) {
    return tc.indexOf(';') === 8;
}

function parseTimecode(tc, timecodeRate, dropFrame) {
    let split = tc.replace(";", ":").split(":", 4);
    let h = parseInt(split[0], 10);
    let m = parseInt(split[1], 10);
    let s = parseInt(split[2], 10);
    let f = parseInt(split[3], 10);
    let timeCode = (h * 3600 + m * 60 + s) * timecodeRate + f;
    if (dropFrame) {
        let D = (int) (timeCode / 17982);
        let M = timeCode % 17982;
        timeCode -= 18 * D + 2 * parseInt((M - 2) / 1798);
    }
    return timeCode;
}

function zeroPad2(n) {
    return n < 10 ? "0" + n : "" + n;
}

function timecodeToString(timeCode, dropFrame, timecodeRate) {
    if (dropFrame) {
        let D = (int) (timeCode / 17982);
        let M = timeCode % 17982;
        timeCode += 18 * D + 2 * (int) ((M - 2) / 1798);
    }

    let frames = timeCode % timecodeRate;
    timeCode = parseInt(timeCode / timecodeRate);
    let seconds = timeCode % 60;
    timeCode = parseInt(timeCode / 60);
    let minutes = timeCode % 60;
    timeCode = parseInt(timeCode / 60);
    let hours = timeCode % 24;
    let tcfmt = "";
    tcfmt += zeroPad2(hours) + ':';
    tcfmt += zeroPad2(minutes) + ':';
    tcfmt += zeroPad2(seconds);
    tcfmt += (dropFrame ? ';' : ':');
    tcfmt += zeroPad2(frames);
    return tcfmt;
}

function getTimecodeAtFrame(startTimecode, frame, dropFrame, tapeFps) {
    return timecodeToString(startTimecode + frame, dropFrame, tapeFps);
}

child.stdout.setEncoding('utf8');
var json = "";
child.stdout.on('data', (chunk) => {
    json += chunk;
});

// since these are streams, you can pipe them elsewhere
child.stderr.pipe(process.stderr);

child.on('close', (code) => {
    let ffp = JSON.parse(json);
    console.log(ffp);
    let streams = [];
    streams = ffp.streams;
    let s = streams.find(s => s.tags && s.tags.timecode);
    let tapeFps = Math.round(s.r_frame_rate.split("/").reduce((num, den) => num / den));
    console.log(s.tags.timecode);
    let frames = parseInt(s.nbframes, 10);
    let dropFrame = isDropFrameString(s.tags.timecode);
    let startTimeCode = parseTimecode(s.tags.timecode, tapeFps, dropFrame);
    let tc = getTimecodeAtFrame(startTimeCode, 4242, dropFrame, tapeFps);
    console.log(tc);
});
