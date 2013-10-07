function videoTouched(event)
{
    var x = event.touches[0].pageX;
    var y = event.touches[0].pageY;
    var i = document.getElementById('video-img');
    var rect = i.getBoundingClientRect();
    
    var cir = {
        x : rect.left + rect.width / 2,
        y : rect.top + rect.width / 2,
        r : rect.width / 2
    }
    var d = (x - cir.x)*(x - cir.x) + (y - cir.y)*(y - cir.y);
    if (d <= cir.r * cir.r)
    {
        window.open('video://Page3.html/tolstoi');
    }
}

var infoShown = 0;

function mapTouched(event)
{
    var x = event.touches[0].pageX;
    var y = event.touches[0].pageY;
    alert('x: ' + x + ' y: ' + y);
    if (infoShown != 0)
    {
        i=document.getElementById('map-info-'+infoShown);
        i.style.opacity = 0;
        setTimeout(function(){infoShown = 0;}, 500);
    }
}

function showMapInfo(n)
{
    i=document.getElementById('map-info-'+n);
    if (infoShown == 0)
    {
        i.style.opacity = 1;
        infoShown = n;
    }
}

function toggleFade()
{
    var b = document.getElementById('moving-block');
    var i = document.getElementById('arrow-img');
    if (b.style.opacity != '1')
    {
        b.style.left = '0px';
        b.style.opacity = '1';
        setTimeout(function(){i.src = 'image/up.png';}, 600);
    }
    else
    {
        b.style.opacity = '0';
        setTimeout(function(){i.src = 'image/down.png';b.style.left = '-4000px';}, 800);
    }
}

var prevPage = 1;

function scrollStory()
{
    var s = document.getElementById('story');
    var c = Math.floor((s.scrollHeight - s.clientHeight) / 10);
    var page = Math.min(Math.max(Math.floor(s.scrollTop / c) + 1, 1), 10);
    if (page != window.prevPage)
    {
        var b = document.getElementById('moving-block-' + page);
        var prev = document.getElementById('moving-block-' + window.prevPage);
        prev.style.opacity = '0';
        b.style.top = '0px'
        b.style.opacity = '1';
        setTimeout(function(){prev.style.top = '-4000px';}, 800);
        window.prevPage = page;
    }
}

function showInfoImage()
{
    var b = document.getElementById('info-img');
    var i = document.getElementById('eye-img');
    if (b.style.opacity != '1')
    {
        b.style.left = '80px';
        b.style.opacity = '1';
        setTimeout(function(){i.src = 'image/text.png';}, 600);
    }
    else
    {
        b.style.opacity = '0';
        setTimeout(function(){i.src = 'image/eye.png';b.style.left = '-4000px';}, 800);
    }
}

var delay;
var playingTrack = 0;

function alertPos(el)
{
    var rect = el.getBoundingClientRect();
    alert('t:' + rect.top + ' l:' + rect.left);
}

function playSound(track)
{
    if (window.playingTrack)
    {
        var s = document.getElementById('sound-' + window.playingTrack);
        s.pause();
        var pt = window.playingTrack;
        soundIsStopped(window.playingTrack);
        if (pt != track) playSound(track);
    }
    else
    {
        var s = document.getElementById('sound-' + track);
        var img = document.getElementById('sound-stop-' + track);
        img.style.display = 'block';
        s.play();
    }
}

function playingIsStarted(track)
{
    window.playingTrack = track;
    var s = document.getElementById('sound-' + track);
    var context = document.getElementById('canvas-' + track).getContext('2d');
    context.save();
    context.lineWidth = '1';
    context.scale(1,0.5);
    context.beginPath();
    context.arc(150, 150, 150, -0.5*Math.PI, 1.5*Math.PI);
    context.strokeStyle = "black";
    context.fillStyle = "rgba(50,50,50,0.5)";
    context.stroke();
    context.fill();
    
    window.delay = setInterval(function(){drawProgressArc(context);}, 10);
    
    function drawProgressArc(context)
    {
        var dur = s.duration;
        var cur = s.currentTime;
        var angle = (cur / dur) * Math.PI * 2;
        context.lineWidth = '8';
        context.beginPath();
        context.arc(150, 150, 35, -0.5*Math.PI, -0.5*Math.PI + angle);
        context.strokeStyle = "rgba(200,200,200,0.8)";
        context.stroke();
    }
}

function soundIsStopped(track)
{
    clearInterval(window.delay);
    var s = document.getElementById('sound-' + track);
    var context = document.getElementById('canvas-' + track).getContext('2d');
    context.clearRect(0,0,400,400);
    context.restore();
    s.currentTime = 0;
    var img = document.getElementById('sound-stop-' + track);
    img.style.display = 'none';
    window.playingTrack = 0;
}

function stopSoundOnLeave()
{
    if (window.playingTrack)
    {
        var s = document.getElementById('sound-' + window.playingTrack);
        s.pause();
        var pt = window.playingTrack;
        soundIsStopped(window.playingTrack);
    }
}

function showMGImg()
{
    var i = document.getElementById('mg-img');
    switch (window.orientation)
    {
        case 0:
        case 180:
            i.src = "image/mg_v.gif";
            break;
        case 90:
        case -90:
            i.src = "image/mg_h.gif";
            break;
    }
}

function changeMGImg(o)
{
    var i = document.getElementById('mg-img');
    i.src = "image/mg_" + o + ".gif";
}
