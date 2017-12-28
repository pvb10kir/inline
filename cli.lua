bot = dofile('/home/spin/inline/utils.lua')
json = dofile('/home/spin/inline/JSON.lua')
URL = require "socket.url"
serpent = require("serpent")
http = require "socket.http"
https = require "ssl.https"
redis = require('redis')
db = redis.connect('127.0.0.1', 6379)
BASE = '/home/spin/inline/'
SUDO = 255317894 -- chief id
sudo_users = {255317894,Userid}
chiefs = {255317894}
BOTS = 459598874 -- bot id
bot_id = db:get(SUDO..'bot_id')
db:set(SUDO..'bot_on',"on")
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function dl_cb(arg, data)
 -- vardump(data)
  --vardump(arg)
end

---------------------setrank Function-------------------------------
function setrank(msg, user, value)
    hash = db:hset('bot:setrank', msg.sender_user_id_, value)
  if hash then
return true 
else 
return false
  end
end
---------------------chek gp-------------------------------#MehTi 

function chackgp(msg) 
local hash = db:sismember('bot:gps', msg.chat_id_)
if hash then
return true
else
return false
end
end
---------------------Sudoers---------------------------------
function is_sudo(msg) 
local hash = db:sismember(SUDO..'sudo:',msg.sender_user_id_)
if hash or is_chief(msg) then
return true
else
return false
end
end
function is_sudoers(msg) 
local hash = db:sismember(SUDO..'helpsudo:',msg.sender_user_id_)
if hash or is_chief(msg) then
return true
else
return false
end
end
------------------------------Admins-------------------------------
function is_admin(msg) 
local hash = db:sismember(SUDO..'admins:',msg.sender_user_id_)
if hash or is_sudo(msg) or is_master(msg) or is_chief(msg) then
return true
else
return false
end
end
------------------------------Master Admin-----------------------------
function is_master(msg) 
  local hash = db:sismember(SUDO..'masters:',msg.sender_user_id_)
if hash or is_sudo(msg) or is_chief(msg) then
return true
else
return false
end
end
-----------------------------Robot-------------------------------
function is_bot(msg)
  if tonumber(BOTS) == 459598874 then
    return true
    else
    return false
    end
  end
  -----------------------------Chief Rank-------------------------------
 function is_chief(msg)
  local var = false
  for k,v in pairs(chiefs) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
-------------------------------Owner-------------------------------
function is_owner(msg) 
 local hash = db:sismember(SUDO..'owners:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_chief(msg) or is_master(msg) or is_admin(msg) then
return true
else
return false
end
end
------------------------------Moderator------------------------------
function is_mod(msg) 
local hash = db:sismember(SUDO..'mods:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_owner(msg) or is_chief(msg) or is_master(msg) or is_admin(msg) then
return true
else
return false
end
end
----------------------------------Vip Users -----------------------------------
function is_vip(msg) 
local hash = db:sismember(SUDO..'vips:',msg.sender_user_id_)
if hash or is_sudo(msg) or is_master(msg) or is_chief(msg) or is_admin(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_banned(chat,user)
   local hash =  db:sismember(SUDO..'banned'..chat,user)
  if hash then
    return true
    else
    return false
    end
	end 
----------------------banall-------------------------------
function is_banall(chat,user)
   local hash =  db:sismember(SUDO..'banalled',user)
  if hash then
    return true
    else
    return false
    end
  end
--------------------------------------------------------------
function edit(chat_id, message_id, text, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = nil,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
}, dl_cb, nil)
--------------------------------------------------------------
end
local function getChatId(chat_id)
  local chat = {}
  local chat_id = tostring(chat_id)

  if chat_id:match('^-100') then
    local channel_id = chat_id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = chat_id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end

  return chat
end
------------------------------------------------------------
function channel_get_bots(channel,cb)
  local function callback_admins(extra,result,success)
    limit = result.member_count_
    bot.getChannelMembers(channel, 0, 'Bots', limit,cb)
  end
  bot.getChannelFull(channel,callback_admins)
end
------------------------------------------------------------
local function getChannelMembers(channel_id, filter, offset, limit, cb, cmd)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset or 0,
    limit_ = limit
  }, cb or dl_cb, cmd)
end
  ------------------------------------------------------------
function is_join(msg)
 local url , res = https.request('https://api.telegram.org/bot496403990:AAGK6T4AAG2cN9u-h9B1Tm1ElSaN_FujQjI/getchatmember?chat_id=-1001056433765&user_id='..msg.sender_user_id_..' ')
   local jdat = json:decode(url)
if jdat.result.status == "left" or jdat.result.status == "kicked" or not jdat.ok then
return false
else
return true
end
end
  ------------------------------------------------------------
  function is_filter(msg, value)
  local hash = db:smembers(SUDO..'filters:'..msg.chat_id_)
  if hash then
    local names = db:smembers(SUDO..'filters:'..msg.chat_id_)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg) then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
  end
  ------------------------------------------------------------
function is_muted(chat,user)
   local hash =  db:sismember(SUDO..'mutes'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
  	-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function priv(chat,user)
  local ohash = db:sismember(SUDO..'owners:'..chat,user)
  local ahash = db:sismember(SUDO..'admins:'..chat,user)
  local mhash = db:sismember(SUDO..'mods:'..chat,user)
  local shash = db:sismember(SUDO..'helpsudo:',user)
  local mahash = db:sismember(SUDO..'masters:',user)
 if tonumber(SUDO) == tonumber(user) or mhash or ohash or shash or mahash or ahash then
   return true
    else
    return false
    end
  end
  ------------------------------------------------------------
function kick(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> You Cant Kick Other Managers!`\nشما اجازه ی اخراج بقیه مدیران را ندارید', 'md')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
    end
  end
  ------------------------------------------------------------
function ban(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> You Cant Ban Other Managers!`\nشما اجازه ی بن کردن بقیه مدیران را ندارید', 'md')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
  db:sadd(SUDO..'banned'..chat,user)
  local t = '`> User `[*'..user..'*]` Successfully Banned!`\nکاربر با موفقیت بن شد.'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t, 1, 'md')
  end
  end
---------------------------ban all -------------------------------
function banall(msg,chat,user)
		if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> You Cant Globally Ban Bot Admins!`\nشما نمیتوانید بقیه مدیران را از تمامی گروه ها بن کنید.', 'md')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
  db:sadd(SUDO..'banalled',user)
  local t = '`> User `[*'..user..'*] `Banned From All Robot Groups!`\nاز تمامی گروه های ربات بن شد.'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t, 1, 'md')
  end
  end
  -----------------------------------------------------------
function mute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> You Cant Mute Other Managers!`\nشما نمیتوانید بقیه مدیران را میوت کنید.', 'md')
    else
  db:sadd(SUDO..'mutes'..chat,user)
  local t = '`> User `[*'..user..'*] `Muted!`\nکاربر با موفقیت میوت شد.'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'md')
  end
  end
  ------------------------------------------------------------
function unban(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem(SUDO..'banned'..chat,user)
  local t = '`> User `[*'..user..'*] `Successfully Unbaned!`'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'md')
  end
  ------------------------------------------------------------
  function unbanall(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem(SUDO..'banalled',user)
  local t = '`> User` [*'..user..'*] `Globally Unbanned!`'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'md')
  end
  ------------------------------------------------------------
function unmute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem(SUDO..'mutes'..chat,user)
  local t = '`> User` [*'..user..'*] `Unmuted!`'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'md')
  end
  ------------------------------------------------------------
 function delete_msg(chatid,mid)
  tdcli_function ({ID="DeleteMessages", chat_id_=chatid, message_ids_=mid}, dl_cb, nil)
end
------------------------------------------------------------
function user(msg,chat,text,user)
  entities = {}
  if text:match('<user>') and text:match('<user>') then
      local x = string.len(text:match('(.*)<user>'))
      local offset = x
      local y = string.len(text:match('<user>(.*)</user>'))
      local length = y
      text = text:gsub('<user>','')
      text = text:gsub('</user>','')
   table.insert(entities,{ID="MessageEntityMentionName", offset_=offset, length_=length, user_id_=user})
  end
    entities[0] = {ID='MessageEntityBold', offset_=0, length_=0}
return tdcli_function ({ID="SendMessage", chat_id_=chat, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_=entities}}, dl_cb, nil)
end
------------------------------------------------------------
function settings(msg,value,lock) 
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
  if value == 'file' then
      text = '> File Has Been'
   elseif value == 'keyboard' then
    text = '> Inline Keyboard Has Been'
   elseif value == 'all' then
    text = '> All Items Has Been'
  elseif value == 'link' then
    text = '> Links Has Been'
  elseif value == 'game' then
    text = '> Game Has Been'
    elseif value == 'username' then
    text = '> UserName Has Been'
   elseif value == 'pin' then
    text = '> Pin Has Been'
    elseif value == 'photo' then
    text = '> Photos Has Been'
    elseif value == 'gif' then
    text = '> Gifs Has Been'
    elseif value == 'video' then
    text = '> Videos Has Been'
    elseif value == 'audio' then
    text = '> Audio & Voice Has Been'
    elseif value == 'music' then
    text = '> Music Has Been'
    elseif value == 'text' then
    text = '> Text Has Been'
    elseif value == 'sticker' then
    text = '> Stickers Has Been'
    elseif value == 'contact' then
    text = '> Contacts Has Been'
    elseif value == 'forward' then
    text = '> Forward Has Been'
    elseif value == 'persian' then
    text = '> Persian Has Been'
    elseif value == 'english' then
    text = '> English Has Been'
    elseif value == 'bot' then
    text = '> Bots Has Been'
    elseif value == 'tgservice' then
    text = '> TGService Has Been'
    else return false
    end
  if lock then
db:set(hash,true)
local id = msg.sender_user_id_
           local lmsg = ' '..text..' LoCkeD! <\n👉 @SpheroNeWs'
            tdcli_function ({
			ID="SendMessage",
			chat_id_=msg.chat_id_,
			reply_to_message_id_=msg.id_,
			disable_notification_=0,
			from_background_=1,
			reply_markup_=nil,
			input_message_content_={ID="InputMessageText",
			text_=lmsg,
			disable_web_page_preview_=1,
			clear_draft_=0,
			 parse_mode_ = md,
			entities_={[0] = {ID="MessageEntityMentionName",
			offset_=0,
			length_=50,
			user_id_=id
			}}}}, dl_cb, nil)
    else
  db:del(hash)
local id = msg.sender_user_id_
           local Umsg = ' '..text..' UnloCkeD! <--\n👉 @SpheroNeWs'
            tdcli_function ({
			ID="SendMessage",
			chat_id_=msg.chat_id_,
			reply_to_message_id_=msg.id_,
			disable_notification_=0,
			from_background_=1,
			reply_markup_=nil,
			input_message_content_={ID="InputMessageText",
			text_=Umsg,
			disable_web_page_preview_=1,
			clear_draft_=0,
			entities_={[0] = {ID="MessageEntityMentionName",
			offset_=0,
			length_=50,
			user_id_=id
			}}}}, dl_cb, nil)
end
end
------------------------------------------------------------
function is_lock(msg,value)
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
 if db:get(hash) then
    return true 
    else
    return false
    end
  end
  
-----------------------------fanection warn------------------------------
function warn(msg,chat,user)
local ch = msg.chat_id_
  local type = db:hget("warn:settings:"..ch,"swarn")
  if type == "kick" then
    kick(msg,chat,user)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..user..'*] `Kicked Because of Max Warns!`\nکاربر به دلیل دریافت اخطار بیش از حد از گروه اخراج شد.', 1,'md')
    end
  if type == "ban" then
    if is_banned(chat,user) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `Banned Because of Max Warns!`\nکاربر به دلیل دریافت اخطار بیش از حد از گروه بن شد.', 1,'md')
      end
bot.changeChatMemberStatus(chat, user, "Kicked")
  db:sadd(SUDO..'banned'..msg.chat_id_,user)
  end
	if type == "mute" then
    if is_muted(msg.chat_id_,user) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `Muted Because of Max Warns!`\nکاربر به دلیل دریافت اخطار بیش از حد میوت شد.','md')
      end
  db:sadd(SUDO..'mutes'..msg.chat_id_,user)
	end
	end
------------------------------------------------------------
function trigger_anti_spam(msg,type)
  if type == "kick" then
    kick(msg,msg.chat_id_,msg.sender_user_id_)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..msg.sender_user_id_..'*] `Kicked For Spamming!`\nکاربر به دلیل ارسال پیام مکرر اخراج شد.', 1,'md')
    end
  if type == "ban" then
    if is_banned(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..msg.sender_user_id_..'*] `Banned For Spamming!`\nکاربر به دلیل ارسال پیام مکرر از گروه بن شد.', 1,'md')
     end
bot.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
  db:sadd(SUDO..'banned'..msg.chat_id_,msg.sender_user_id_)
 
  end
	if type == "mute" then
    if is_muted(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..msg.sender_user_id_..'*] `Muted For Spamming!`\nکاربر به دلیل ارسال پیام مکرر میوت شد', 1,'md')
    end
  db:sadd(SUDO..'mutes'..msg.chat_id_,msg.sender_user_id_)
	end
	end
function televardump(msg,value)
  local text = json:encode(value)
  bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 'html')
  end
------------------------------------------------------------
function run(msg,data)
   --vardump(data)
  --televardump(msg,data)
    if msg then
            db:incr(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
      if msg.send_state_.ID == "MessageIsSuccessfullySent" then
      return false 
      end
      end	
   
    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
    local text = msg.content_.text_
	if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
		text = text
		end
    --------- messages type -------------------
    if msg.content_.ID == "MessageText" then
      msg_type = 'text'
    end

	if msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD")
    msg_type = 'MSG:NewUserAdd'
	end
	
    if msg.content_.ID == "MessageChatJoinByLink" then
      msg_type = 'join'
    end
    if msg.content_.ID == "MessagePhoto" then
      msg_type = 'photo'
      end
    -------------------------------------------
    if msg_type == 'text' and text then
      if text:match('^[/#!]') then
      text = text:gsub('^[/#!]','')
      end
    end
     if text then
      if not db:get(SUDO..'bot_id') then
         function cb(a,b,c)
         db:set(SUDO..'bot_id',b.id_)
         end
      bot.getMe(cb)
      end
    end
 ------------------------------------------------------------
if not is_join(msg) and is_mod(msg) then
bot.sendMessage(msg.chat_id_, msg.id_, 1, 'سلام، مدیر گرامی!\nبرای دستور دادن به ربات ضروری است که در کانال ربات جوین باشید\nاز شما تقاضا میشود که در کانال ربات جوین شوید تا دیگر هرگز با این پیام مواجه نشوید.\nکانال ربات : @SpheroNews\nبا تشکر', 1, 'html')
else
if chat_type == 'super' then
--------------------------gp add -------------------------
if text == 'install' and is_master(msg) then
if db:sismember('bot:gps', msg.chat_id_) then
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>> Group is Already In Added! | قبلا اضافه شده است!</code>\nربات از قبل در این گروه فعال است.\n> @SpheroNews', 1, 'html')
else
db:sadd('bot:gps', msg.chat_id_)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>> Group Added! | انجام شد</code>\nربات با موفقیت در گروه نصب شد.\nلذا برای فعال شدن ربات در گروه باید لینک گروه را ارسال کنید\nنمونه:\n/glink https://t.me/joinchat/DzfXhkKXqCI2KiGTRhhfAw\n> @SpheroNews', 1, 'html')
end
	end
		end
--------------------------rem add -------------------------
if text == 'uninstall' and is_master(msg) then
if not db:sismember('bot:gps', msg.chat_id_) then
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>> Group is Not Added! | از قبل ادد نشده است.!</code>\nربات قبلا در این گروه ادد نشده است.\n> @SpheroNews', 1, 'html')
else			
db:srem('bot:gps', msg.chat_id_)
db:del(SUDO..'mods:'..msg.chat_id_)
db:del(SUDO..'owners:'..msg.chat_id_)
db:del(SUDO..'banned'..msg.chat_id_)
db:del('bot:rules'..msg.chat_id_)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>> RemoVed! | انجام شد</code>\nربات به دستور ادمین غیرفعال شده و گروه خارج میشود.\n> @SpheroNews', 1, 'html')
end
	end
--------------------------set link -----------------------
if text and text:match('^glink (.*)') and is_owner(msg) then
local link = text:match('glink (.*)')
db:set(SUDO..'grouplink'..msg.chat_id_, link)
bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>> لینک جدید با موفقیت ذخیر شد.</code>\nربات در گروه شما فعال شد!\n > @SpheroNews', 1, 'html')
end
----------------------start prozhect ----------------------
if chackgp(msg) then 
local chcklink = db:get(SUDO..'grouplink'..msg.chat_id_) 
if not chcklink and is_owner(msg) then 
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>> صاحب گرامی گروه!</code>\nاز شما تقاضا میشود که لینک گروه خود را با دستور زیر ثبت کنید تا ربات در گروه شما فعال شود.\n/glink [لینک گروه]\n> @SpheroNews', 1, 'html')
else 
local ch = msg.chat_id_
local user_id = msg.sender_user_id_
floods = db:hget("flooding:settings:"..ch,"flood") or  'nil'
max_msg = db:hget("flooding:settings:"..ch,"floodmax") or 5
max_time = db:hget("flooding:settings:"..ch,"floodtime") or 3
------------------Flooding----------------------------#Mehti
if db:hget("flooding:settings:"..ch,"flood") then
if not is_mod(msg) then
if msg.content_.ID == "MessageChatAddMembers" then 
return false
else 
	local post_count = tonumber(db:get('floodc:'..msg.sender_user_id_..':'..msg.chat_id_) or 0)
	if post_count > tonumber(db:hget("flooding:settings:"..ch,"floodmax") or 5) then
 local ch = msg.chat_id_
         local type = db:hget("flooding:settings:"..ch,"flood")
         trigger_anti_spam(msg,type)
 end
	db:setex('floodc:'..msg.sender_user_id_..':'..msg.chat_id_, tonumber(db:hget("flooding:settings:"..msg.chat_id_,"floodtime") or 3), post_count+1)
end
end
end
local edit_id = data.text_ or 'nil' --bug #behrad
	 local ch = msg.chat_id_
    max_msg = 5
    if db:hget("flooding:settings:"..ch,"floodmax") then
       max_msg = db:hget("flooding:settings:"..ch,"floodmax")
      end
    if db:hget("flooding:settings:"..ch,"floodtime") then
		max_time = db:hget("flooding:settings:"..ch,"floodtime")
      end
-- save pin message id
  if msg.content_.ID == 'MessagePinMessage' then
 if is_lock(msg,'pin') and is_owner(msg) then
 db:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
  elseif not is_lock(msg,'pin') then
 db:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
 end
 end
 -- check filters
    if text and not is_mod(msg) then
     if is_filter(msg,text) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end 
    end
	
-- end charge expire -- 


local exp = tonumber(db:get('bot:charge:'..msg.chat_id_))
                if exp == 0 then
				exp_dat = 'Unlimited'
				else
			local now = tonumber(os.time())
      if not now then 
      now = 0 
      end
      if not exp then
      exp = 0
      end
			exp_dat = (math.floor((tonumber(exp) - tonumber(now)) / 86400) + 1)      
end
if exp_dat == 1 and is_owner(msg) and not is_sudo(msg) and not is_master(msg) and is_admin(msg) and is_chief(msg) then 
local texter = 'شارژ گروه شما تا 1 روز دیگر به پایان میرسد⚠️\nبهتر است برای شارژ گروه خود اقدام کنید✌️\nتعرفه خرید ربات: https://t.me/SpheroNews/730\n> @SpheroNews'
bot.sendMessage(msg.chat_id_,0,1,texter,0,'md')
end

if exp_dat == 0 and is_owner(msg) and not is_sudo(msg) and not is_master(msg) and is_admin(msg) and is_chief(msg) then
function getchat(arg,data)
db:del('bot:charge:'..msg.chat_id_)
local link = db:get(SUDO..'grouplink'..msg.chat_id_) 
local owner = db:sismember(SUDO..'owners:'..msg.chat_id_)
local texter = 'شارژ گروه به پایان رسید.⚠️\nربات لغو نصب شد.\nبرای خرید دوباره ربات بر روی لینک زیر بزنید\nhttps://t.me/SpheroNews/730\n> @SpheroNews'
db:srem('bot:gps', msg.chat_id_)
bot.sendMessage(SUDO, msg.id_, 1,'شارژ گروهی با اطلاعات زیر به پایان رسید.\n*Gp Name : *'..data.title_..'\n*Link : *'..link..' \n*Owner :* '..owner..'\n@SpheroNews', 1, 'md')
bot.sendMessage(msg.chat_id_,0,1,texter,0,'md')
bot.changeChatMemberStatus(msg.chat_id_, 249464384, "Left")
	end
 bot.getChat(msg.chat_id_,getchat) 
end
 if text == 'leave' and is_master(msg) then
function getchat(arg,data)
db:del('bot:charge:'..msg.chat_id_)
local link = db:get(SUDO..'grouplink'..msg.chat_id_) 
local texter = 'ربات به دستور ادمین از گروه خارج میشود.\n> @SpheroNews'
db:srem('bot:gps', msg.chat_id_)
bot.sendMessage(SUDO, msg.id_, 1,'.ربات از گروهی با اطلاعات زیر لفت داد\n\n*Link : *'..link..'\n*GroupName :*'..data.title_..'\n> @SpheroNews', 1, 'md')
bot.changeChatMemberStatus(msg.chat_id_, BOTS, "Left")
end
end
 ----------------------------------
-- check settings
    
     -- lock tgservice
      if is_lock(msg,'tgservice') then
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" or msg.content_.ID == "MessageChatDeleteMember" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
		
 ---------------edit masg----------------#MehTi	
	
    -- lock pin
    if is_owner(msg) then else
      if is_lock(msg,'pin') then
        if msg.content_.ID == 'MessagePinMessage' then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>> پیام سنجاق شده توسط ادمین قفل شده است!</code>\n<code>شما در ربات دارای مقام نمیباشید و اجازه پین کردن پیامی را ندارید\n> @SpheroNews</code>',1, 'html')
      bot.unpinChannelMessage(msg.chat_id_)
          local PinnedMessage = db:get(SUDO..'pinned'..msg.chat_id_)
          if PinnedMessage then
             bot.pinChannelMessage(msg.chat_id_, tonumber(PinnedMessage), 0)
            end
          end
        end
      end
      if is_mod(msg) then
        else
        -- lock link
        if is_lock(msg,'link') then
          if text then
        if msg.content_.entities_ and msg.content_.entities_[0] and msg.content_.entities_[0].ID == 'MessageEntityUrl' or msg.content_.text_.web_page_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:match("[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or text:match("[Tt].[Mm][Ee]/")
            if is_link then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock username
        if is_lock(msg,'username') then
          if text then
       local is_username = text:match("@[%a%d]")
        if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_username = text:match("@[%a%d]")
            if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
		
        -- lock sticker 
        if is_lock(msg,'sticker') then
          if msg.content_.ID == 'MessageSticker' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
end
          end
        -- lock forward
        if is_lock(msg,'forward') then
          if msg.forward_info_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
          end
        -- lock photo
        if is_lock(msg,'photo') then
          if msg.content_.ID == 'MessagePhoto' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock file
        if is_lock(msg,'file') then
          if msg.content_.ID == 'MessageDocument' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
      -- lock file
        if is_lock(msg,'keyboard') then
          if msg.reply_markup_ and msg.reply_markup_.ID == 'ReplyMarkupInlineKeyboard' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
      -- lock game
        if is_lock(msg,'game') then
          if msg.content_.game_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock music 
        if is_lock(msg,'music') then
          if msg.content_.ID == 'MessageAudio' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock voice 
        if is_lock(msg,'audio') then
          if msg.content_.ID == 'MessageVoice' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock gif
        if is_lock(msg,'gif') then
          if msg.content_.ID == 'MessageAnimation' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end 
        -- lock contact
        if is_lock(msg,'contact') then
          if msg.content_.ID == 'MessageContact' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock video 
        if is_lock(msg,'video') then
          if msg.content_.ID == 'MessageVideo' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
           end
          end
        -- lock text 
        if is_lock(msg,'text') then
          if msg.content_.ID == 'MessageText' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock persian 
        if is_lock(msg,'persian') then
          if text:match('[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_persian = text:match("[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]")
            if is_persian then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock english 
        if is_lock(msg,'english') then
          if text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_english = text:match("[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]")
            if is_english then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock bot
        if is_lock(msg,'bot') then
       if msg.content_.ID == "MessageChatAddMembers" then
            if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
              end
            end
          end
      end

-- check mutes
      local muteall = db:get(SUDO..'muteall'..msg.chat_id_)
      if msg.sender_user_id_ and muteall and not is_mod(msg) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
      if msg.sender_user_id_ and is_muted(msg.chat_id_,msg.sender_user_id_) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
-- check bans
    if msg.sender_user_id_ and is_banned(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User Is Not Is BanList!`\nکاربر مسدود نمیباشد.',1, 'md')
      end
-- check banalls	  
    if msg.sender_user_id_ and is_banall(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banall(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User Is Already Globally Banned!`\nکاربر از قبل گلوبال بن میباشد.',1, 'md')
      end	    
-- welcome
    local status_welcome = (db:get(SUDO..'status:welcome:'..msg.chat_id_) or 'disable') 
    if status_welcome == 'enable' then
			    if msg.content_.ID == "MessageChatJoinByLink" then
        if not is_banned(msg.chat_id_,msg.sender_user_id_) and not is_banall(msg.chat_id_,msg.sender_user_id_) then
     function wlc(extra,result,success)
        if db:get(SUDO..'welcome:'..msg.chat_id_) then
        t = db:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name} {username}\nخوش اومدی!\n> @SpheroNews'
        end
      local t = t:gsub('{name}',result.first_name_)
      local t = t:gsub('{username}',result.username_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
          end
        bot.getUser(msg.sender_user_id_,wlc)
      end
        end
        if msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].type_.ID == 'UserTypeGeneral' then

    if msg.content_.ID == "MessageChatAddMembers" then
      if not is_banned(msg.chat_id_,msg.content_.members_[0].id_) and not is_banall(msg.chat_id_,msg.content_.members_[0].id_) then
      if db:get(SUDO..'welcome:'..msg.chat_id_) then
        t = db:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش اومدی!\n> @SpheroNews'
        end
      local t = t:gsub('{name}',msg.content_.members_[0].first_name_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
      end
        end
          end
      end
      -- locks
    if text and is_owner(msg) then
      local lock = text:match('^lock pin$')
       local unlock = text:match('^unlock pin$')
      if lock then
          settings(msg,'pin','lock')
          end
        if unlock then
          settings(msg,'pin')
        end
      end 
    if text and is_mod(msg) then
---------------lock by #MehTi---------------
	if text:match('^lock (.*)$') then
       local lock = text:match('^lock (.*)$')   
	   local locks = {"all","Flood","Spam","Link","markdown","tag","username","english","arabic","fwd","reply","emoji","edit","Pin","Cmd","Addmember","Joinmember","Bot","photo","video","gif","sticker","document","inline","text","audio","location","contact"}
local suc = 0
for i,v in pairs(locks) do
if lock == v:lower() then
suc = 1
settings(msg,lock,'lock')
end 
end 
if suc == 0 then
bot.sendMessage(msg.chat_id_, msg.id_, 1,'`> Is Not in My Lock List`\nدر لیست چنین قفلی وجود ندارد.', 1, 'md')
end
end


------------------------------------------------
 ----------------Lock By #MehTi-----------------
if text:match('^unlock (.*)$') then
local unlock = text:match('^unlock (.*)$')   
local locks = {"all","Flood","Spam","Link","markdown","tag","username","english","arabic","fwd","reply","emoji","edit","Pin","Cmd","Addmember","Joinmember","Bot","photo","video","gif","sticker","document","inline","text","audio","location","contact"}
local suc = 0
for i,v in pairs(locks) do
if unlock == v:lower() then
suc = 1
settings(msg,unlock)
end 
end 
if suc == 0 then
bot.sendMessage(msg.chat_id_, msg.id_, 1,'`> Is Not in My Lock List`\nدر لیست چنین قفلی وجود ندارد.', 1, 'md')
end
end
-------------------end lock ---------------------------#MehTi 
 
       local unlock = text:match('^unlock (.*)$')
      local pin = text:match('^lock pin$') or text:match('^unlock pin$')
      if pin and is_owner(msg) then
        elseif pin and not is_owner(msg) then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما دسترسی کافی برای استفاده از این قسمت را ندارید!</code>',1, 'html') 
        end
        end
    
 -- lock flood settings
    if text and is_owner(msg) then
	   local ch = msg.chat_id_
      if text == 'flood kick' then
      db:hset("flooding:settings:"..ch ,"flood",'kick') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Flood Has Been Locked!`\n*Status :*`Kick`',1, 'md')
      elseif text == 'flood ban' then
        db:hset("flooding:settings:"..ch ,"flood",'ban') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Flood Has Been Locked!`\n*Status :*`Ban`',1, 'md')
        elseif text == 'flood mute' then
        db:hset("flooding:settings:"..ch ,"flood",'mute') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Flood Has Been Locked!`\n*Status :*`Mute`',1, 'md')
        elseif text == 'unlock flood' then
        db:hdel("flooding:settings:"..ch ,"flood") 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Flood Has Been Unlocked!`',1, 'md')
            end
          end
       
        -- sudo
    if text then
	
  -------------------info------------------------
if text:match('^info$') or text:match('^me$') then
function info(extra,result,success)
       if is_chief(msg) then
    t = 'Chief (High Rank|⭐️⭐️⭐️⭐️⭐️⭐️🌟)'
      elseif is_sudoers(msg) or is_sudo(msg) then
    t = 'Bot Sudo(⭐️⭐️⭐️⭐️⭐️⭐️)'
      elseif is_master(msg) then
    t = 'Bot Master Admin(⭐️⭐️⭐️⭐️⭐️)'
      elseif is_admin(msg) then
    t = 'Bot Admin(⭐️⭐️⭐️⭐️⭐️)'
    elseif is_owner(msg) then
    t = 'Group Owner(⭐️⭐️⭐️)'
    elseif is_mod(msg) then
    t = 'Group Moderator(⭐️⭐️)'
    elseif is_vip(msg) then
    t = 'Vip User(💫)'
    else
    t = 'Member⭐️'
    end
if result.username_ then
              username = '@'..result.username_
            else
                username = '----'
              end
            if result.last_name_ then
              lastname = result.last_name_
            else
              lastname = '----'
            end
local user = msg.sender_user_id_
local usermsg = db:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
local maxwarn = tonumber(db:hget("warn:settings:"..msg.chat_id_ ,"warnmax") or 3)
local warns = tonumber(db:hget("warn:settings:"..msg.chat_id_,msg.sender_user_id_) or 0)
local info = '<b>➖Name :</b> <code>'..result.first_name_..'</code>\n<b>➖Last Name :</b> <code>'..lastname..'</code>\n<b>➖Username :</b> '..username..'\n<b>➖User ID :</b> <code>'..user..'</code>\n<b>➖Rank :</b> <code>'..t..'</code>\n<b>➖Total Messages :</b> <code>'..usermsg..'</code>\n<b>➖Total Warns :</b> <code>'..warns..'</code> <b>of</b> <code>'..maxwarn..'</code>\n<b>➖Join</b> > @SpheroNews'
bot.sendMessage(msg.chat_id_, msg.id_, 1, info, 1, 'html')
  end
bot.getUser(msg.sender_user_id_,info)
	end

  -------------------id+pro------------------------#MehTi
	if text == 'id' then  
	if db:get("id:"..msg.chat_id_..":"..msg.sender_user_id_) then
	local ttl = db:ttl("id:"..msg.chat_id_..":"..msg.sender_user_id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, 'شما به تازگی از این دستور استفاده کرده اید\n*'..ttl..'* ثانیه دیگر امتحان کنید.', 'md')
  		else
if is_chief(msg) then
    t = 'Chief (High Rank)'
      elseif is_sudoers(msg) then
    t = 'Bot Sudo'
      elseif is_master(msg) then
    t = 'Master Admin'
      elseif is_admin(msg) then
    t = 'Bot Admin'
    elseif is_owner(msg) then
    t = 'Group Owner'
    elseif is_mod(msg) then
    t = 'Group Moderator'
    elseif is_vip(msg) then
    t = 'Vip User(💫)'
    else
    t = 'Member⭐️'
    end
	db:setex("id:"..msg.chat_id_..":"..msg.sender_user_id_, 20, true)
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '*-Your ID* > `'..msg.sender_user_id_..'`\n*-Group ID* > `'..msg.chat_id_..'`\n*-Rank* > `'..t..'`\n> @SpheroNews', 1, 'md')
   end
	end
-----------------  set sudoers -------------------- #MehTi
	          if text == 'addsudo' and is_chief(msg) then
          function sudo_reply(extra, result, success)
        db:sadd(SUDO..'sudo:',result.sender_user_id_)
		db:srem(SUDO..'owners:'..result.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `Added To SudoList`', 1, 'md')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),sudo_reply)
          end
        end
        if text and is_sudo(msg) and text:match('^addsudo (%d+)') then
          local user = text:match('addsudo (%d+)')
          db:sadd(SUDO..'sudo:',user)
		  db:srem(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `Added To SudoList`', 1, 'md')
			end
		if text and text:match('^addsudo @(.*)') then
        local username = text:match('addsudo @(.*)')
        function addsudo(extra,result,success)
          if result.id_ then
           db:sadd(SUDO..'sudo:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `Added To SudoList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,addsudo)
        end
--------------- dem sudoers -----------------------#MehTi 
        if text == 'remsudo' and is_chief(msg) then
        function sudo_reply(extra, result, success)
        db:srem(SUDO..'sudo:',result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.sender_user_id_..'*] `RemoVed From SudoList`', 1, 'md')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),sudo_reply)  
          end
        end
        if text and text:match('^remsudo (%d+)') and is_sudo(msg) then
          local user = text:match('remsudo (%d+)')
         db:srem(SUDO..'sudo:',user)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `RemoVed From SudoList`', 1, 'md')
       end
			if text and text:match('^remsudo @(.*)') then
        local username = text:match('remsudo @(.*)')
        function remsudo(extra,result,success)
          if result.id_ then
           db:srem(SUDO..'sudo:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `RemoVed From SudoList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,remsudo)
        end
	------------------------------------------------------------
	if text:match('^update') and is_sudo(msg) then
	text = io.popen("git pull "):read('*all')
	  dofile('./cli.lua') 
	 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Cli And Api Bot Reload And Updated!`\n*Git Pull Result:*\n_'..text..'_', 1, 'md')
	end
--------------- text -----------------------------------  
	        if is_master(msg) then
-----------ban all ------------------
    if text == 'banall' then
		if msg.reply_to_message_id_ == 0 then
        local user = msg.sender_user_id_
        bot.sendMessage(msg.chat_id_, msg.id_, 1, "`روی فرد مورد نظر ریپلی کنید سپس دستور را دوباره ارسال کنید.`", 1, 'md')
        else
        function banreply(extra, result, success)
        banall(msg,msg.chat_id_,result.sender_user_id_)
          end
		  end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
		      if text and text:match('^banall (%d+)') then
        banall(msg,msg.chat_id_,text:match('^banall (%d+)'))
        end
      if text and text:match('^banall @(.*)') then
        local username = text:match('banall @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            banall(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,banusername)
        end
----------------------unbanall-----------------------------
        if text == 'unbanall' then
		if msg.reply_to_message_id_ == 0 then
        local user = msg.sender_user_id_
        bot.sendMessage(msg.chat_id_, msg.id_, 1, "`روی فرد مورد نظر ریپلی کنید سپس دستور را دوباره ارسال کنید.`", 1, 'md')
		else
        function unbanreply(extra, result, success)
        unbanall(msg,msg.chat_id_,result.sender_user_id_)
          end
		  end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end	
      if text and text:match('^unbanall (%d+)') then
        unbanall(msg,msg.chat_id_,text:match('unbanall (%d+)'))
        end
      if text and text:match('^unbanall @(.*)') then
        local username = text:match('unbanall @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unbanall(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unbanusername)
end
----------------------------------------------------------		
       if text == 'addowner' then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `Added To OwnerList`', 1, 'md')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^addowner (%d+)$') then
          local user = text:match('^addowner (%d+)$')
          db:sadd(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `Added To OwnerList`', 1, 'md')
end
	if text and text:match('^addowner @(.*)') then
        local username = text:match('addowner @(.*)')
        function addowner(extra,result,success)
          if result.id_ then
         db:sadd(SUDO..'owners:'..msg.chat_id_,result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `Added To OwnerList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,addowner)
        end	
        if text == 'remowner' then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.sender_user_id_..'*] `RemoVed From OwnerList`', 1, 'md')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text and text:match('^remowner (%d+)') then
          local user = text:match('remowner (%d+)')
         db:srem(SUDO..'owners:'..msg.chat_id_,user)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..user..'*] `RemoVed From OwnerList`', 1, 'md') 
			end
				end
		if text and text:match('^remowner @(.*)') then
        local username = text:match('remowner @(.*)')
        function remowner(extra,result,success)
          if result.id_ then
         db:srem(SUDO..'owners:'..msg.chat_id_,result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `RemoVed From OwnerList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,remowner)
        end	
      --------------------------master--------------------------
 if text == 'addmaster' then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'masters:',result.sender_user_id_)
        local master = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..master..'*] `Added To MasterList`', 1, 'md')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^addmaster (%d+)') then
          local master = text:match('addmaster (%d+)')
          db:sadd(SUDO..'masters:',master)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..master..'*] `Added To MasterList`', 1, 'md')
	end
		if text and text:match('^addmaster @(.*)') then
        local username = text:match('addmaster @(.*)')
        function addmaster(extra,result,success)
          if result.id_ then
         db:sadd(SUDO..'masters:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `Added To MasterList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,addmaster)
        end
        if text == 'remmaster' then
        function prom_reply(extra, result, success)
	local master = result.sender_user_id_
        db:srem(SUDO..'masters:',result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..master..'*] `RemoVed From MasterList`', 1, 'md')
		end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        if text and text:match('^remmaster (%d+)') then
          local master = text:match('remmaster (%d+)')
         db:srem(SUDO..'masters:',master)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..master..'*] `RemoVed From MasterList`', 1, 'md')
		end	 
end
	if text and text:match('^remmaster @(.*)') then
        local username = text:match('remmaster @(.*)')
        function remmaster(extra,result,success)
          if result.id_ then
         db:srem(SUDO..'masters:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `RemoVed From MasterList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,remmaster)
        end
---------------------vip users-------------------------
if text == 'addvip' then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'vips:',result.sender_user_id_)
        local vip = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..vip..'*] `Added To VipUsers`', 1, 'md')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^addvip (%d+)') then
          local vip = text:match('addvip (%d+)')
          db:sadd(SUDO..'vips:',vip)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..vip..'*] `Added To VipUsers`', 1, 'md')
	end
		if text and text:match('^addvip @(.*)') then
        local username = text:match('addvip @(.*)')
        function addvip(extra,result,success)
          if result.id_ then
         db:sadd(SUDO..'vips:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `Added To VipUsers`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,addvip)
        end
        if text == 'remvip' then
        function prom_reply(extra, result, success)
	local vip = result.sender_user_id_
        db:srem(SUDO..'vips:',vip)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..vip..'*] `RemoVed From VipUsers`', 1, 'md')
		end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        if text and text:match('^remvip (%d+)') then
          local vip = text:match('remvip (%d+)')
         db:srem(SUDO..'vips:',vip)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..vip..'*] `RemoVed From VipUsers`', 1, 'md')
		end	 
end
	if text and text:match('^remvip @(.*)') then
        local username = text:match('remvip @(.*)')
        function remvip(extra,result,success)
          if result.id_ then
         db:srem(SUDO..'vips:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `RemoVed From VipUsers`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,remvip)
        end
---------------------admins-------------------------
if text == 'addadmin' then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'admins:',result.sender_user_id_)
        local admin = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..admin..'*] `Added To AdminsList`', 1, 'md')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^addadmin (%d+)') then
          local admin = text:match('addadmin (%d+)')
          db:sadd(SUDO..'admins:',admin)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..admin..'*] `Added To AdminsList`', 1, 'md')
	end
		if text and text:match('^addadmin @(.*)') then
        local username = text:match('addadmin @(.*)')
        function addadmin(extra,result,success)
          if result.id_ then
         db:sadd(SUDO..'admins:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `Added To AdminsList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,addadmin)
        end
        if text == 'remadmin' then
        function prom_reply(extra, result, success)
	local admin = result.sender_user_id_
        db:srem(SUDO..'admins:',admin)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..admin..'*] `RemoVed From AdminsList`', 1, 'md')
		end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        if text and text:match('^remadmin (%d+)') then
          local admin = text:match('remadmin (%d+)')
         db:srem(SUDO..'admins:',admin)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User `[*'..admin..'*] `RemoVed From AdminsList`', 1, 'md')
		end	 
end
	if text and text:match('^remadmin @(.*)') then
        local username = text:match('remadmin @(.*)')
        function remadmin(extra,result,success)
          if result.id_ then
         db:srem(SUDO..'admins:',result.id_)
	bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> User` [*'..result.id_..'*] `RemoVed From AdminsList`', 1, 'md')
            else 
            text = '<code>> User Not Found!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,remadmin)
        end
---------------------reload -------------------------
	   if text == 'reload' and is_sudo(msg) then
       dofile('./cli.lua')
 bot.sendMessage(msg.chat_id_, msg.id_, 1,'*50%*', 1, 'md')
bot.edit(msg.chat_id_, msg.id_, '*> Reloaded!✅*', 'md')
            end
if text == 'stats' and is_admin(msg) then
	local gps = db:scard("botgp")
	local users = db:scard("usersbot")
	local allmgs = db:get("allmsg")
	local sudos = db:scard(SUDO..'sudo:')
	local admins = db:scard(SUDO..'admins:')
	local vips = db:scard(SUDO..'vips:')
	local masters = db:scard(SUDO..'masters:')
	local gban =  db:scard(SUDO..'banalled')
		bot.sendMessage(msg.chat_id_, msg.id_, 1, '*> Bot Stats!*\n\n`>> SuperGroups :` *'..gps..'*\n`>> Users : `*'..users..'*\n`>> All Messages :` *'..allmgs..'*\n`>> Sudos :` *'..sudos..'*\n`>> Master Admins :` *'..masters..'*\n`>> Admins :` *'..admins..'*\n`>> Vip Users :` *'..vips..'*\n`>> Global Bans :` *'..gban..'*\n> @SpheroNews', 1, 'md')
	end
	  -----------------owner------------------------
      -- owner
	  if is_owner(msg) then
          if text == 'remlink' then
            db:del(SUDO..'grouplink'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لینک تنظیم شده با موفقیت بازنشانی گردید.</code>', 1, 'html')
            end
            if text and text:match('^setname (.*)') then
            local name = text:match('^setname (.*)')
            bot.changeChatTitle(msg.chat_id_, name)
            end
        if text == 'welcome enable' then
          db:set(SUDO..'status:welcome:'..msg.chat_id_,'enable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>ارسال پیام خوش آمدگویی فعال گردید.</code>', 1, 'html')
          end
        if text == 'welcome disable' then
          db:set(SUDO..'status:welcome:'..msg.chat_id_,'disable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>ارسال پیام خوش آمدگویی غیرفعال گردید.</code>', 1, 'html')
          end
        if text and text:match('^setwelcome (.*)') then
          local welcome = text:match('^setwelcome (.*)')
          db:set(SUDO..'welcome:'..msg.chat_id_,welcome)
          local t = '<code>>پیغام خوش آمدگویی با موفقیت ذخیره و تغییر یافت.</code>\n<code>>متن پیام خوش آمدگویی تنظیم شده:</code>:\n{<code>'..welcome..'</code>}'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
        if text == 'delete welcome' then
          db:del(SUDO..'welcome:'..msg.chat_id_,welcome)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>پیغام خوش آمدگویی بازنشانی گردید و به حالت پیشفرض تنظیم شد.</code>', 1, 'html')
          end
        if text == 'owners' or text == 'ownerlist' then
          local list = db:smembers(SUDO..'owners:'..msg.chat_id_)
          local t = '<code>>لیست مالکین گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nبرای مشاهده کاربر از دستور زیر استفاده کنید \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<code>>لیست مالکان گروه خالی میباشد!</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    if text == 'modset' then
        function prom_reply(extra, result, success)
        db:sadd(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^modset @(.*)') then
        local username = text:match('^modset @(.*)')
        function promreply(extra,result,success)
          if result.id_ then
        db:sadd(SUDO..'mods:'..msg.chat_id_,result.id_)
        text ='<code>>کاربر</code> [<code>'..result.id_..'</code>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>' 
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,promreply)
        end
        if text and text:match('^modset (%d+)') then
          local user = text:match('modset (%d+)')
          db:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
      end
        if text == 'moddem' then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..result.sender_user_id_..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^moddem @(.*)') then
        local username = text:match('^moddem @(.*)')
        function demreply(extra,result,success)
          if result.id_ then
        db:srem(SUDO..'mods:'..msg.chat_id_,result.id_)
        text = '<code>>کاربر</code> [<b>'..result.id_..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>'
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,demreply)
        end
        if text and text:match('^modset (%d+)') then
          local user = text:match('modset (%d+)')
          db:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
      end
        if text and text:match('^moddem (%d+)') then
          local user = text:match('moddem (%d+)')
         db:srem(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>', 1, 'html')
      end
  end
      end
	----------------------Clean List------------------------
	if is_mod(msg) then
          if text:match("^[Cc]lean (.*)$") then
            local txt = {string.match(text, "^([Cc]lean) (.*)$")}
            if txt[2] == 'banlist' then
              db:del(SUDO..'banned'..msg.chat_id_)
                send(msg.chat_id_, msg.id_, 1, '`> Banlist CleaneD!`', 1, 'md')
              end
            if is_sudo(msg) then
              if txt[2] == 'gbanlist' then
                db:del(SUDO..'banalled')
                  send(msg.chat_id_, msg.id_, 1, '`> GBanlist CleaneD!`', 1, 'md')
              end
            end
            if txt[2] == 'bots' then
	local function g_bots(extra,result,success)
                local bots = result.members_
                for i=0 , #bots do
                  chat_kick(msg.chat_id_, bots[i].user_id_)
                end
              end
              channel_get_bots(msg.chat_id_,g_bots)
                bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> All Bots RemoVed From Group!`', 1, 'md')
            end
            if txt[2] == 'modlist' then
		db:del(SUDO..'mods:'..msg.chat_id_)
                bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Modlist CleaneD!`', 1, 'md')
            end
            if txt[2] == 'viplist' then
		db:del(SUDO..'vips')
                 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Viplist CleaneD!`', 1, 'md')
            end
            if txt[2] == 'filterlist' then
		db:del(SUDO..'filters:'..msg.chat_id_)
                 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Filterlist CleaneD!`', 1, 'md')
              end
            if txt[2] == 'ownerlist' then
              db:del(SUDO..'owners:'..msg.chat_id_)
                 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Ownerlist CleaneD!`', 1, 'md')
              end
            if txt[2] == 'mutelist' then
              db:del(SUDO..'mutes'..msg.chat_id_)
                 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Mutelist CleaneD!`', 1, 'md')
            end
	   if txt[2] == 'adminlist' then
              db:del(SUDO..'admins')
                 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Adminlist CleaneD!`', 1, 'md')
		end
	   if txt[2] == 'masterlist' then
              db:del(SUDO..'masters')
                 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Masterlist CleaneD!`', 1, 'md')
		end
	   if txt[2] == 'sudolist' then
		db:del(SUDO..'sudo')
                 bot.sendMessage(msg.chat_id_, msg.id_, 1, '`> Sudolist CleaneD!`', 1, 'md')
              end
          end
        end
 	if text:match("^edit (.*)$") and is_admin(msg) then
	local editmsg = {string.match(text, "^(edit) (.*)$")} 
		 edit(msg.chat_id_, msg.reply_to_message_id_, nil, editmsg[2], 1, 'md')
    end
---on bot --------

             if db:get(SUDO..'bot_on') == "on" then
			 		local url , res = http.request('http://irapi.ir/time')
		if res ~= 200 then
			return "No connection"
end
	local jdat = json:decode(url)
			 local idgp = 304107094
			 local text = '🔴*The robot went online*\n➖➖➖➖➖➖➖➖\n🔹*Time:* `'..jdat.ENtime..'`\n➖➖➖➖➖➖➖➖\n🔸*Date:* `'..jdat.FAdate..'`\n➖➖➖➖➖➖➖➖\n'
			 bot.sendMessage(idgp, 0, 1,text, 1, 'md')
			 db:del(SUDO..'bot_on')
			end
	  
-- mods
    if is_owner(msg) or is_sudoers(msg) or is_mod(msg) then
      local function getsettings(value)
        if value == 'muteall' then
        local hash = db:get(SUDO..'muteall'..msg.chat_id_)
        if hash then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
        elseif value == 'welcome' then
        local hash = db:get(SUDO..'welcome:'..msg.chat_id_)
        if hash == 'enable' then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
        elseif value == 'spam' then
		local ch = msg.chat_id_
        local hash = db:hget("flooding:settings:"..ch,"flood")
        if hash then
             if db:hget("flooding:settings:"..ch, "flood") == "kick" then
         return '<code>User-kick</code>'
              elseif db:hget("flooding:settings:"..ch,"flood") == "ban" then
              return '<code>User-ban</code>'
							elseif db:hget("flooding:settings:"..ch,"flood") == "mute" then
              return '<code>Mute</code>'
              end
          else
          return '<code>مجاز</code>'
          end
        elseif is_lock(msg,value) then
          return '<code>غیرمجاز</code>'
          else
          return '<code>مجاز</code>'
          end
        end
        ---------------------------------------------------
      if text == 'panel' then
          function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = 0,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 496403990,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(msg.chat_id_),
      offset_ = 0
    }, inline, nil)
       end
	   --[[if text == 'muteslist' then
        local text = '><b>Group-Filterlist:</b>\n<b>----------------</b>\n'
        ..'><code>Filter-Photo:</code> |'..getsettings('photo')..'|\n'
        ..'><code>Filter-Video:</code> |'..getsettings('video')..'|\n'
        ..'><code>Filter-Audio:</code> |'..getsettings('voice')..'|\n'
        ..'><code>Filter-Gifs:</code> |'..getsettings('gif')..'|\n'
        ..'><code>Filter-Music:</code> |'..getsettings('music')..'|\n'
        ..'><code>Filter-File:</code> |'..getsettings('file')..'|\n'
        ..'><code>Filter-Text:</code> |'..getsettings('text')..'|\n'
        ..'><code>Filter-Contacts:</code> |'..getsettings('contact')..'|\n'
        ..'><code>Filter-Forward:</code> |'..getsettings('forward')..'|\n'
        ..'><code>Filter(Inline-mod):</code> |'..getsettings('game')..'|\n'
        ..'><code>Filter-Service(Join):</code> |'..getsettings('tgservice')..'|\n'
        ..'><code>Mute-Chat:</code> |'..getsettings('muteall')..'|\n'
        bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, '')
       end]]
      if text and text:match('^floodmax (%d+)$') then
		local ch = msg.chat_id_
          db:hset("flooding:settings:"..ch ,"floodmax" ,text:match('floodmax (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>حداکثر پیام تشخیص ارسال پیام مکرر تنظیم شد به:</code> [<b>'..text:match('floodmax (.*)')..'</b>] <code>تغییر یافت.</code>', 1, 'html')
        end
        if text and text:match('^floodtime (%d+)$') then
		local ch = msg.chat_id_
          db:hset("flooding:settings:"..ch ,"floodtime" ,text:match('floodtime (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>حداکثر زمان تشخیص ارسال پیام مکرر تنظیم شد به:</code> [<b>'..text:match('floodtime (.*)')..'</b>] <code>ثانیه.</code>', 1, 'html')
        end
        if text == 'link' then
          local link = db:get(SUDO..'grouplink'..msg.chat_id_) 
          if link then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '➖➖➖➖➖➖➖➖➖\n<b>🌐Group Link👇</b>\n\n👉 '..link..'\n➖➖➖➖➖➖➖➖➖\n⚜️ @BanG_TeaM', 1, 'html')
            else
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>لینک ورود به گروه تنظیم نشده است.</code>\n<code>ثبت لینک جدید با دستور</code>\n<b>/setlink</b> <i>link</i>\n<code>امکان پذیر است.</code>', 1, 'html')
            end
          end
        if text == 'mutechat' then
          db:set(SUDO..'muteall'..msg.chat_id_,true)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '⚜️<code>Mute Chat</code> <b>Has Been Enabled🔇</b>', 1, 'html')
          end
        if text and text:match('^mutechat (%d+)[mhs]') or text and text:match('^mutechat (%d+) [mhs]') then
          local matches = text:match('^mutechat (.*)')
          if matches:match('(%d+)h') then
          time_match = matches:match('(%d+)h')
          time = time_match * 3600
          end
          if matches:match('(%d+)s') then
          time_match = matches:match('(%d+)s')
          time = time_match
          end
          if matches:match('(%d+)m') then
          time_match = matches:match('(%d+)m')
          time = time_match * 60
          end
          local hash = SUDO..'muteall'..msg.chat_id_
          db:setex(hash, tonumber(time), true)
          bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>فیلتر تمامی گفتگو ها برای مدت زمان</code> [<b>'..time..'</b>] <code>ثانیه فعال گردید.</code>', 1, 'html')
          end
        if text == 'unmutechat' then
          db:del(SUDO..'muteall'..msg.chat_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '⚜️<code>Mute Chat</code> <b>Has Been Disabled🔈</b>', 1, 'html')
          end
        if text == 'mutechat status' then
          local status = db:ttl(SUDO..'muteall'..msg.chat_id_)
          if tonumber(status) < 0 then
            t = 'زمانی برای آزاد شدن چت تعییین نشده است !'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
            else
          t = '[<b>'..status..'</b>] <code>ثانیه دیگر تا غیرفعال شدن فیلتر تمامی گفتگو ها باقی مانده است.</code>'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
          end
-------------------------------------------------------------------------
      if text == 'kick' and tonumber(msg.reply_to_message_id_) > 0 then
        function kick_by_reply(extra, result, success)
        kick(msg,msg.chat_id_,result.sender_user_id_)
			text1 = '<code>کاربر مورد نظر اخراج شد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text1, 1, 'html')
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),kick_by_reply)
        end
		
      if text and text:match('^kick (%d+)') then
        kick(msg,msg.chat_id_,text:match('kick (%d+)'))
		            text1 = '<code>کاربر مورد نظر اخراج شد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text1, 1, 'html')
        end
      if text and text:match('^kick @(.*)') then
        local username = text:match('^kick @(.*)')
        function kick_username(extra,result,success)
          if result.id_ then
            kick(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,kick_username)
				  		            text2 = '<code>کاربر مورد نظر اخراج شد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text2, 1, 'html')
        end
		
        if text == 'ban' and tonumber(msg.reply_to_message_id_) > 0 then
        function banreply(extra, result, success)
        ban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
      if text and text:match('^ban (%d+)') then
        ban(msg,msg.chat_id_,text:match('^ban (%d+)'))
				            text1 = '<code>کاربر مورد نظر بن شد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text1, 1, 'html')
        end
      if text and text:match('^ban @(.*)') then
        local username = text:match('ban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            ban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,banusername)
				            text1 = '<code>کاربر مورد نظر بن شد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text1, 1, 'html')
        end
      if text == 'unban' and tonumber(msg.reply_to_message_id_) > 0 then
        function unbanreply(extra, result, success)
        unban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end
      if text and text:match('^unban (%d+)') then
        unban(msg,msg.chat_id_,text:match('unban (%d+)'))
        end
      if text and text:match('^unban @(.*)') then
        local username = text:match('unban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unbanusername)
        end
        if text == 'silentuser' and tonumber(msg.reply_to_message_id_) > 0 then
        function mutereply(extra, result, success)
        mute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),mutereply)
        end
      if text and text:match('^silentuser (%d+)') then
        mute(msg,msg.chat_id_,text:match('silentuser (%d+)'))
        end
      if text and text:match('^silentuser @(.*)') then
        local username = text:match('silentuser @(.*)')
        function muteusername(extra,result,success)
          if result.id_ then
            mute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,muteusername)
        end
      if text == 'unsilentuser' and tonumber(msg.reply_to_message_id_) > 0 then
        function unmutereply(extra, result, success)
        unmute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unmutereply)
        end
      if text and text:match('^unsilentuser (%d+)') then
        unmute(msg,msg.chat_id_,text:match('unsilentuser (%d+)'))
        end
      if text and text:match('^unsilentuser @(.*)') then
        local username = text:match('unsilentuser @(.*)')
        function unmuteusername(extra,result,success)
          if result.id_ then
            unmute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unmuteusername)
        end
         if text == 'invite' and tonumber(msg.reply_to_message_id_) > 0 then
        function inv_by_reply(extra, result, success)
        bot.addChatMembers(msg.chat_id_,{[0] = result.sender_user_id_})
        end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),inv_by_reply)
        end
      if text and text:match('^invite (%d+)') then
        bot.addChatMembers(msg.chat_id_,{[0] = text:match('invite (%d+)')})
        end
      if text and text:match('^invite @(.*)') then
        local username = text:match('invite @(.*)')
        function invite_username(extra,result,success)
          if result.id_ then
        bot.addChatMembers(msg.chat_id_,{[0] = result.id_})
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,invite_username)
        end  
		
    ----------warn settings --------------
	
	if text and text:match('^warnmax (%d+)$') then
		local ch = msg.chat_id_
        db:hset("warn:settings:"..ch ,"warnmax" ,text:match('warnmax (%d+)'))
        bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>حداکثر اخطار به تعداد:</code> [<b>'..text:match('warnmax (.*)')..'</b>] <code>تغییر یافت.</code>', 1, 'html')
end
-- lock flood settings
if text and is_owner(msg) then
local ch = msg.chat_id_
if text == 'warn kick' then
db:hset("warn:settings:"..ch ,"swarn",'kick') 
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>وضعیت اخطار در گروه تغییر کرد</code> \n<code>وضعیت</code> > <i>اخراج(کاربر)</i>',1, 'html')
elseif text == 'warn ban' then
db:hset("warn:settings:"..ch ,"swarn",'ban') 
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>وضعیت اخطار در گروه تغییر کرد</code> \n<code>وضعیت</code> > <i>مسدود-سازی(کاربر)</i>',1, 'html')
elseif text == 'warn mute' then
db:hset("warn:settings:"..ch ,"swarn",'mute') 
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>وضعیت اخطار در گروه تغییر کرد</code> \n<code>وضعیت</code> > <i>سکوت(کاربر)</i>',1, 'html')
elseif text == 'warn reset' then
db:hset("warn:settings:"..ch ,"swarn",'kick') 
bot.sendMessage(msg.chat_id_, msg.id_, 1, ' <code>وضعیت اخطار در گروه به حالت پیشفرض تغییر کرد </code> ',1, 'html')
end
end

---------------------------------------------------------------------

      if text == 'warn' and tonumber(msg.reply_to_message_id_) > 0 then
		function swarn_by_reply(extra, result, success)
		local nwarn = tonumber(db:hget("warn:settings:"..result.chat_id_,result.sender_user_id_) or 0)
	    local wmax = tonumber(db:hget("warn:settings:"..result.chat_id_ ,"warnmax") or 3)
		if nwarn == wmax then
	    db:hset('warn:settings:'..result.chat_id_,result.sender_user_id_,0)
         warn(msg,msg.chat_id_,result.sender_user_id_)
		 else 
		db:hset('warn:settings:'..result.chat_id_,result.sender_user_id_,nwarn + 1)
		bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>انجام شد کاربر['..result.sender_user_id_..']به دلیل عدم رعایت ['..(nwarn + 1)..'/'..wmax..']اخطار دریافت کرد</code>',1, 'html')
		end  
		end 
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),swarn_by_reply)
	end 
-----------del msg sudo -------------
        
      if  text and text:match('^del (%d+)$') then
        local limit = tonumber(text:match('^del (%d+)$'))
        if limit > 1000 then
         bot.sendMessage(msg.chat_id_, msg.id_, 1, 'تعداد پیام وارد شده از حد مجاز (1000 پیام) بیشتر است !', 1, 'html')
          else
------------------------------------
         function cb(a,b,c)
        local msgs = b.messages_
        for i=1 , #msgs do
          delete_msg(msg.chat_id_,{[0] = b.messages_[i].id_})
        end
        end
------------------------------------
        bot.getChatHistory(msg.chat_id_, 0, 0, limit + 1,cb)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, limit..' پیام اخیر گروه پاک شد !', 1, 'html')
-------------------------------------
        end
        end
      if tonumber(msg.reply_to_message_id_) > 0 then
    if text == "del" then
        delete_msg(msg.chat_id_,{[0] = tonumber(msg.reply_to_message_id_),msg.id_})
    end
        end
-----------------------------------------------
    if text == 'mods' or text == 'modlist' then
          local list = db:smembers(SUDO..'mods:'..msg.chat_id_)
          local t = '`> Modlist | لیست مدیران گروه`\n\n'
          for k,v in pairs(list) do
          t = t..k.." - `"..v.."`\n" 
          end
          t = t..'\n> @SpheroNews'
          if #list == 0 then
          t = '`> This Group Does Not Have Moderator! | این گروه فاقد مدیر است.`'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
      if text and text:match('^filter +(.*)') then
        local w = text:match('^filter +(.*)')
         db:sadd(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'`> Word` [*'..w..'*] `Added To FilterList`', 1, 'md')
       end
      if text and text:match('^unfilter +(.*)') then
        local w = text:match('^unfilter +(.*)')
         db:srem(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'`> Word` [*'..w..'*] `RemoVed From FilterList`', 1, 'md')
       end
----------------------------------------------
      if text == 'admins' or text == 'adminlist' then
        local function cb(extra,result,success)
        local list = result.members_
           local t = '<code>>لیست ادمین های گروه:</code>\n\n'
          local n = 0
            for k,v in pairs(list) do
           n = (n + 1)
              t = t..n.." - "..v.user_id_.."\n"
                    end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>', 1, 'html')
          end
       bot.channel_get_admins(msg.chat_id_,cb)
      end
------------------------------------------
      if text == 'filterlist' then
          local list = db:smembers(SUDO..'filters:'..msg.chat_id_)
          local t = '<code>>لیست کلمات فیلتر شده در گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - "..v.."\n" 
          end
          if #list == 0 then
          t = '<code>>لیست کلمات فیلتر شده خالی میباشد</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    if text == 'bans' or text == 'banlist' then
          local list = db:smembers(SUDO..'banned'..msg.chat_id_)
          local t = '<code>>لیست افراد مسدود شده از گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code>\n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>لیست افراد مسدود شده از گروه خالی میباشد.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end	
-------------------------------------		
   if text == 'banalls' or text == 'gbanlist' then
          local list = db:smembers(SUDO..'banalled')
          local t = '<code>>لیست افراد مسدود شده از گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code>\n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>لیست افراد مسدود شده از گروه خالی میباشد.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
		
        if text == 'mutes' or text == 'silentlist' then
          local list = db:smembers(SUDO..'mutes'..msg.chat_id_)
          local t = '<code>لیست کاربران حالت سکوت</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = 'لیست افراد میوت شده خالی است !'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end      
    local msgs = db:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
    if msg_type == 'text' then
        if text then
      if text:match('^whois @(.*)') then
        local username = text:match('^whois @(.*)')
        function id_by_username(extra,result,success)
          if result.id_ then
            text = '<b>⚜️Your UserID</b> 👉 [<code>'..result.id_..'</code>]\n<b>⚜️Your Msg Send<b> 👉 <code>'..(db:get(SUDO..'total:messages:'..msg.chat_id_..':'..result.id_) or 0)..'</code>'
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,id_by_username)
        end
          if text == 'gpid' then
            if tonumber(msg.reply_to_message_id_) == 0 then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه-گروه</code>: {<b>'..msg.chat_id_..'</b>}', 1, 'html')
          end
            end
-----------------------------------------------------------			
if text == 'autoc' then
if not limit or limit > 200 then
limit = 200
end
local function GetMod(extra,result,success)
local c = result.members
for i=0 , #c do
  db:sadd(SUDO..'mods:'..msg.chat_id,c[i].user_id)
 end
bot.sendMessage(msg.chat_id_, msg.id_, "All Group Admins Become Moderator! | تمام ادمین های گروه مدیر ربات شدند.\n------------------------\n*Send* /mods *For See Admins!*", "md")
end
bot.getChannelMembers(msg.chat_id,'Administrators',0,limit,GetMod)
end
-------------------Charge Groups -------------#MehTi

        if text and text:match('charge (%d+)') and is_sudoers(msg) then
              local chare = text:match('charge (%d+)')
if tonumber(chare) < 0 or tonumber(chare) > 999 then
bot.sendMessage(msg.chat_id_, msg.id_, 1, '*Error*\n_Wrong Number ,Range Is [1-999]_', 1,'md')
else
		local time = os.time()
		local buytime = tonumber(os.time())
		local timeexpire = tonumber(buytime) + (tonumber(chare) * 86400)
    db:set('bot:charge:'..msg.chat_id_,timeexpire)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '*👉Done✅*\n_⚜️Group Charging_ 》 `'..chare..' Day`', 1,'md')
end 
end 


----------fun------------------

---------------------time ------------------
if text:match('time') then
		local url , res = http.request('http://irapi.ir/time')
		if res ~= 200 then
			return "No connection"
		end
		local colors = {'blue','green','yellow','magenta','Orange','DarkOrange','red'}
		local fonts = {'mathbf','mathit','mathfrak','mathrm'}
		local jdat = json:decode(url)
		local url = 'http://latex.codecogs.com/png.download?'..'\\dpi{600}%20\\huge%20\\'..fonts[math.random(#fonts)]..'{{\\color{'..colors[math.random(#colors)]..'}'..jdat.ENtime..'}}'
		local file = download_to_file(url,'time.webp')
		bot.sendDocument(msg.to.id, 0, 0, 1, nil, file, '', dl_cb, nil)
end
--------------------voice-------------------
if text:match('voice (.+)') then
local matches = text:match('voice (.+)')
 local text = matches
    textc = text:gsub(' ','.')

  local url = "http://tts.baidu.com/text2audio?lan=en&ie=UTF-8&text="..textc
  local file = download_to_file(url,'MehTi.mp3')
 				bot.sendDocument(msg.chat_id_, 0, 0, 1, nil, file, 'done', dl_cb, nil)
  
end
--------------------tr-----------------------
	if text:match('tr (.+) (.+)') then 
	local matches = text:match('tr (.+) (.+)')
		url = https.request('https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160119T111342Z.fd6bf13b3590838f.6ce9d8cca4672f0ed24f649c1b502789c9f4687a&format=plain&lang='..URL.escape(matches[2])..'&text='..URL.escape(matches[3]))
		data = json:decode(url)
		local text = 'زبان : '..data.lang..'\nترجمه : '..data.text[1]..''
		bot.sendMessage(msg.chat_id_, 0, 1, text, 1, 'html')
end
------------------weather---------------------
local function get_weather(location)
	print("Finding weather in ", location)
	local BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
	local url = BASE_URL
	url = url..'?q='..location..'&APPID=eedbc05ba060c787ab0614cad1f2e12b'
	url = url..'&units=metric'
	local b, c, h = http.request(url)
	if c ~= 200 then return nil end
	local weather = json:decode(b)
	local city = weather.name
	local country = weather.sys.country
	local temp = 'دمای شهر '..city..' هم اکنون '..weather.main.temp..' درجه سانتی گراد می باشد'
	local conditions = 'شرایط فعلی آب و هوا : '
	if weather.weather[1].main == 'Clear' then
		conditions = conditions .. 'آفتابی☀'
	elseif weather.weather[1].main == 'Clouds' then
		conditions = conditions .. 'ابری ☁☁'
	elseif weather.weather[1].main == 'Rain' then
		conditions = conditions .. 'بارانی ☔'
	elseif weather.weather[1].main == 'Thunderstorm' then
		conditions = conditions .. 'طوفانی ☔☔☔☔'
	elseif weather.weather[1].main == 'Mist' then
		conditions = conditions .. 'مه 💨'
	end
	return temp .. '\n' .. conditions
end
	if text:match('weather (.+)') then 
	local matches = text:match('weather (.+)')
		city = matches
		local wtext = get_weather(city)
		if not wtext then
			wtext = 'مکان وارد شده صحیح نیست'
		bot.sendMessage(msg.chat_id_, 0, 1, wtext, 1, 'html')
		end
		return wtext
end

---end fun --------------


------------------set rules ----------------------#MehTi
  	if text:match("^setrules (.*)$") and is_mod(msg) then
	local txt = {string.match(text, "^(setrules) (.*)$")}
	db:set('bot:rules'..msg.chat_id_, txt[2])
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '_Group rules upadted..._', 1, 'md')
    end
----------------------get rules-------------------------#MehTi
  	if text:match("^rules$") then
	local rules = db:get('bot:rules'..msg.chat_id_)
	bot.sendMessage(msg.chat_id_, msg.reply_to_message_id_, 1, rules, 1, 'html')
end
----------------------Pin------------------------------#MehTi
			if text == 'pin' then			
if msg.reply_to_message_id_ == 0 then
bot.sendMessage(msg.chat_id_, msg.id_, 1, '*Wtf?!*', 1,'md')
else 
bot.pinChannelMessage(msg.chat_id_,msg.reply_to_message_id_,0)
bot.sendMessage(msg.chat_id_, msg.reply_to_message_id_, 1, "<code>>پیام مورد نظر شما پین شد.</code>", 1, 'html')
db:set(SUDO..'pinned'..msg.chat_id_,msg.reply_to_message_id_)
   end
   end 
			 if text == 'bot' then
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>BOT Online!</b>', 1, 'html')
      end
        if text and text:match('whois (%d+)') then
              local id = text:match('whois (%d+)')
            local text = 'برای مشاهده اطلاعات کاربر کلیک کنید.'
			--{"👤 برای مشاهده کاربر کلیک کنید!","Click to view User 👤"}
            tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=36, user_id_=id}}}}, dl_cb, nil)
              end
        if text == "whois" then
        function id_by_reply(extra, result, success)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه:</code> [<b>'..result.sender_user_id_..'</b>]\n<code>تعداد پیام های ارسالی:</code> [<b>'..(db:get(SUDO..'total:messages:'..msg.chat_id_..':'..result.sender_user_id_) or 0)..'</b>]', 1, 'html')
        end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),id_by_reply)
      end
        end

          end
        end
      end
   -- member
   if text == 'ping' then
          local a = {"<i>I Am Online *_*</i>","<b>Pong!</b>"}
          bot.sendMessage(msg.chat_id_, msg.id_, 1,''..a[math.random(#a)]..'', 1, 'html')
      end
	  db:incr("allmsg")
	  if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not db:sismember("botgp",msg.chat_id_) then  
            db:sadd("botgp",msg.chat_id_)
			 -- db:incrby("g:pa")
        end
        elseif id:match('^(%d+)') then
        if not db:sismember("usersbot",msg.chat_id_) then
            db:sadd("usersbot",msg.chat_id_)
			--db:incrby("pv:mm")
        end
        else
        if not db:sismember("botgp",msg.chat_id_) then
            db:sadd("botgp",msg.chat_id_)
			 -- db:incrby("g:pa")
        end
     end
    end
	  if text == 'number' then
         local number = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","43","45","46","47","48","49","50"}  
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>Your Random Number:</b>\n [<code>'..number[math.random(#number)]..'</code>]', 1, 'html')
      end
    if text and msg_type == 'text' and not is_muted(msg.chat_id_,msg.sender_user_id_) then
end
end
  -- help 
  if text and text == 'help' then
    if is_sudoers(msg) then
help = [[متن راهنمای مالک ربات ثبت نشده است.]]

  elseif is_owner(msg) then
    help = [[
	<code>>راهنمای مالکین گروه(اصلی-فرعی)</code>
*<b>[/#!]settings</b> --<code>دریافت تنظیمات گروه</code>
*<b>[/#!]setrules</b> --<code>تنظیم قوانین گروه</code>
*<b>[/#!]modset</b> @username|reply|user-id --<code>تنظیم مالک فرعی جدید برای گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]moddem</b> @username|reply|user-id --<code>حذف مالک فرعی از گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]ownerlist</b> --<code>دریافت لیست مدیران اصلی</code>
*<b>[/#!]managers</b> --<code>دریافت لیست مدیران فرعی گروه</code>
*<b>[/#!]setlink</b> <code>link</code> <code>{لینک-گروه} --تنظیم لینک گروه</code>
*<b>[/#!]link</b> <code>دریافت لینک گروه</code>
*<b>[/#!]kick</b> @username|reply|user-id <code>اخراج کاربر با ریپلی|یوزرنیم|شناسه</code>
<b>-------------------------------</b>
<code>>راهنمای بخش حذف ها</code>
*<b>[/#!]delete managers</b> <code>{حذف تمامی مدیران فرعی تنظیم شده برای گروه}</code>
*<b>[/#!]delete welcome</b> <code>{حذف پیغام خوش آمدگویی تنظیم شده برای گروه}</code>
*<b>[/#!]delete bots</b> <code>{حذف تمامی ربات های موجود در ابرگروه}</code>
*<b>[/#!]delete silentlist</b> <code>{حذف لیست سکوت کاربران}</code>
*<b>[/#!]delete filterlist</b> <code>{حذف لیست کلمات فیلتر شده در گروه}</code>
<b>-------------------------------</b>
<code>>راهنمای بخش خوش آمدگویی</code>
*<b>[/#!]welcome enable</b> --<code>(فعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]welcome disable</b> --<code>(غیرفعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]setwelcome text</b> --<code>(تنظیم پیغام خوش آمدگویی جدید در گروه)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلترگروه</code>
*<b>[/#!]mutechat</b> --<code>فعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]unmutechat</b> --<code>غیرفعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]mutechat number(h|m|s)</b> --<code>فیلتر تمامی گفتگو ها بر حسب زمان[ساعت|دقیقه|ثانیه]</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات حالت سکوت کاربران</code>
*<b>[/#!]silentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]unsilentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]silentlist</b> <code>--دریافت لیست کاربران حالت سکوت</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلتر-کلمات</code>
*<b>[/#!]filter word</b> <code>--افزودن عبارت جدید به لیست کلمات فیلتر شده</code>
*<b>[/#!]unfilter word</b> <code>--حذف عبارت جدید از لیست کلمات فیلتر شده</code>
*<b>[/#!]filterlist</b> <code>--دریافت لیست کلمات فیلتر شده</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات تنظیمات ابر-گروه[فیلترها]</code>
*<b>[/#!]lock|unlock link</b> --<code>(فعال سازی/غیرفعال سازی ارسال تبلیغات)</code>
*<b>[/#!]lock|unlock username</b> --<code>(فعال سازی/غیرفعال سازی ارسال یوزرنیم)</code>
*<b>[/#!]lock|unlock sticker</b> --<code>(فعال سازی/غیرفعال سازی ارسال برچسب)</code>
*<b>[/#!]lock|unlock contact</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  مخاطبین)</code>
*<b>[/#!]lock|unlock english</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(انگلیسی))</code>
*<b>[/#!]lock|unlock persian</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(فارسی))</code>
*<b>[/#!]lock|unlock forward</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  فوروارد)</code>
*<b>[/#!]lock|unlock photo</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  تصاویر)</code>
*<b>[/#!]lock|unlock video</b> --<code>(فعال سازی/غیرفعال سازی فیلتر ویدئو)</code>
*<b>[/#!]lock|unlock gif</b> --<code>(فعال سازی/غیرفعال سازی فیلتر تصاویر-متحرک)</code>
*<b>[/#!]lock|unlock music</b> --<code>(فعال سازی/غیرفعال سازی فیلتر آهنگ(MP3))</code>
*<b>[/#!]lock|unlock audio</b> --<code>(فعال سازی/غیرفعال سازی فیلتر صدا(Voice-Audio))</code>
*<b>[/#!]lock|unlock text</b> --<code>(فعال سازی/غیرفعال سازی فیلتر متن)</code>
*<b>[/#!]lock|unlock keyboard</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  درون-خطی(کیبرد شیشه))</code>
*<b>[/#!]lock|unlock tgservice</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  پیام ورود-خروج افراد)</code>
*<b>[/#!]lock|unlock pin</b> --<code>(مجاز/غیرمجاز کردن پین پیام توسط عضو عادی)</code>
*<b>[/#!]lock|unlock number(h|m|s)</b> --<code>(مجاز/غیرمجاز کردن ارسال پیغام مکرر)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش تنظیم پیغام مکرر</code>
*<b>[/#!]floodmax number</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر</code>
*<b>[/#!]floodtime</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر برحسب زمان</code>
]]
   elseif is_mod(msg) then
    help = [[از متن راهنمای مالکین گروه استفاده کنید.]]
    elseif not is_mod(msg) then
    help = [[متن راهنما برای کاربران عادی ثبت نشده است.]]
    end
   bot.sendMessage(msg.chat_id_, msg.id_, 1, help, 1, 'html')
  end
  end
  ----end check gp ----------
  end
  end
function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
     run(data.message_,data)
elseif data.ID == 'UpdateMessageEdited' then
if not is_mod(msg) and db:get('edit:Lock:'..data.chat_id_) == "lock" then
bot.deleteMessages(data.chat_id_,{[0] = data.message_id_})
end 
    local function edited_cb(extra,result,success)
      run(result,data)
    end
     tdcli_function ({
      ID = "GetMessage",
      chat_id_ = data.chat_id_,
      message_id_ = data.message_id_
    }, edited_cb, nil)
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
end
  end
