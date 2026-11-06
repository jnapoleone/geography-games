/* Progress sync: sends right/wrong results to a private Google Sheet so reviews can target what gets missed.

   Sends ONLY: a random device id, card/question/section ids, right/wrong, scores, timestamps. No name, no answers typed, nothing else.
   Never changes or removes the games' own saved progress. If anything here fails, the games carry on as normal.
   ENDPOINT is an add-only Google Apps Script URL (sync/Code.gs). It cannot be used to read the Sheet.
   Results wait on the device and are sent later if there's no connection. */
(function(){
"use strict";
var ENDPOINT="https://script.google.com/macros/s/AKfycbwA_rs4NWPW_bnP_wCU0H4Azy3Tm4V9kHgqbk6DRNdNg0UFjGNyba8spzSzPwx1BLA/exec";   /* the Apps Script web app URL. Empty = sync is off and this file does nothing. */
var P="geoSync.",K_DEV=P+"device",K_Q=P+"queue",K_BF=P+"backfilled",K_NOTE=P+"noteSeen";
var BATCH=200,MAX_QUEUE=3000,RETRY_MS=60000;
var NOTE="Your Geography right and wrong answers now go to a private sheet your dad can see, with no name attached, so your reviews get built around what you miss.";

var API={on:false,note:NOTE,log:function(){},flush:function(){}};
window.Sync=API;
if(!ENDPOINT)return;

var mem=[],memOnly=false,busy=false,nextTry=0,timer=null,seq=0;
function get(k){try{return localStorage.getItem(k)}catch(e){return null}}
function put(k,v){try{localStorage.setItem(k,v);return true}catch(e){return false}}
function parse(k){try{return JSON.parse(get(k))}catch(e){return null}}
function readQ(){if(memOnly)return mem;var q=parse(K_Q);return Array.isArray(q)?q:[]}
function writeQ(q){if(q.length>MAX_QUEUE)q=q.slice(q.length-MAX_QUEUE);if(!memOnly&&!put(K_Q,JSON.stringify(q))){memOnly=true}mem=q}

function randomId(){
  try{var b=new Uint8Array(6);crypto.getRandomValues(b);return Array.prototype.map.call(b,function(x){return("0"+x.toString(16)).slice(-2)}).join("")}
  catch(e){return(Math.random().toString(16).slice(2)+"000000000000").slice(0,12)}
}
var dev=get(K_DEV);if(!/^[0-9a-f]{12}$/.test(dev||"")){dev=randomId();put(K_DEV,dev)}

var path=location.pathname.match(/\/(swipe)(\/|$)/);
var APP=path?path[1]:"basecamp";

function slug(s){return String(s).replace(/[^A-Za-z0-9]+/g,"-").replace(/^-+|-+$/g,"").slice(0,60)}
function make(id,at,app,kind,item,result,value){
  return{id:id,at:at,app:app,kind:kind,item:item==null?"":String(item),result:result==null?"":String(result),value:value==null?"":String(value)};
}

function log(kind,item,result,value){
  try{
    var now=new Date(),q=readQ();
    q.push(make(dev+"-"+now.getTime().toString(36)+"-"+(seq++),now.toISOString(),APP,kind,item,result,value));
    writeQ(q);
    clearTimeout(timer);timer=setTimeout(flush,4000);
  }catch(e){}
}

/* First run on a device: copy what's already saved there, so history isn't lost. Ids are fixed, so it can't double-count. */
function backfill(){
  if(get(K_BF))return;
  var out=[],now=new Date().toISOString();
  function add(at,app,kind,item,result,value,idTail){
    out.push(make("bf-"+dev+"-"+kind+"-"+(idTail||item||"x"),at||now,app,kind,item,result,value));
  }
  var w=parse("geoSwipe.v1");
  if(w&&typeof w==="object"){
    var wAt=w.last||now;
    if(w.sessions)add(wAt,"swipe","past_sessions","","",w.sessions,"swipe");
    Object.keys(w.miss||{}).forEach(function(id){add(wAt,"swipe","past_miss",id,"",w.miss[id])});
    Object.keys(w.topics||{}).forEach(function(t){var v=w.topics[t]||{};add(wAt,"swipe","past_topic",slug(t),"","r"+(v.r||0)+"w"+(v.w||0))});
    Object.keys(w.decks||{}).forEach(function(d){var v=w.decks[d]||{};add(wAt,"swipe","past_deck",d,"","best"+(v.best||0)+"runs"+(v.runs||0))});
  }
  var b=parse("geo-best");
  if(b&&typeof b==="object"){
    Object.keys(b).forEach(function(d){if(b[d]!=null)add(now,"basecamp","past_best",d,"",b[d]+"of10","basecamp-"+d)});
  }
  writeQ(readQ().concat(out));
  put(K_BF,now);
}

function flush(leaving){
  try{
    if(busy&&!leaving)return;
    if(!leaving&&Date.now()<nextTry)return;
    var batch=readQ().slice(0,BATCH);
    if(!batch.length)return;
    var opts={method:"POST",headers:{"Content-Type":"text/plain;charset=utf-8"},credentials:"omit",cache:"no-store",redirect:"follow",body:JSON.stringify({d:dev,e:batch})};
    if(leaving){opts.keepalive=true;fetch(ENDPOINT,opts).catch(function(){});return} /* kept in the queue; the Sheet ignores repeats */
    busy=true;
    fetch(ENDPOINT,opts).then(function(r){return r.json()}).then(function(j){
      busy=false;
      if(!j||j.ok!==true)throw 0;
      var sent={};batch.forEach(function(e){sent[e.id]=1});
      var left=readQ().filter(function(e){return !sent[e.id]});
      writeQ(left);
      nextTry=0;
      if(left.length)flush();
    }).catch(function(){busy=false;nextTry=Date.now()+RETRY_MS});
  }catch(e){busy=false}
}

/* A one-time heads-up on whichever page he opens first. */
function showNote(){
  if(get(K_NOTE))return;
  var d=document.createElement("div");
  d.setAttribute("role","status");
  d.style.cssText="position:fixed;left:12px;right:12px;bottom:calc(12px + env(safe-area-inset-bottom,0px));z-index:9999;max-width:480px;margin:0 auto;background:#17191f;color:#f1f2f4;border:1px solid #3a3e48;border-radius:12px;padding:14px;font:500 15px/1.4 system-ui,-apple-system,sans-serif;box-shadow:0 8px 28px rgba(0,0,0,.45)";
  var p=document.createElement("div");p.textContent=NOTE;
  var b=document.createElement("button");b.type="button";b.textContent="Got it";
  b.style.cssText="display:block;margin:10px 0 0 auto;min-height:40px;padding:0 16px;background:#f1f2f4;color:#17191f;border:0;border-radius:8px;font:600 15px system-ui,-apple-system,sans-serif;cursor:pointer";
  b.onclick=function(){put(K_NOTE,new Date().toISOString());d.remove()};
  d.appendChild(p);d.appendChild(b);document.body.appendChild(d);
}

API.on=true;API.log=log;API.flush=flush;
try{backfill()}catch(e){}
log("open");
document.addEventListener("visibilitychange",function(){if(document.visibilityState==="hidden")flush(true)});
window.addEventListener("pagehide",function(){flush(true)});
window.addEventListener("online",function(){nextTry=0;flush()});
if(document.body)showNote();else document.addEventListener("DOMContentLoaded",showNote);
})();
