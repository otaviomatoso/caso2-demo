@ECHO OFF
SET LUA_CPATH=%LUA_CPATH%;C:\Users\AgBr\AppData\Roaming\LuaRocks\lib\lua\5.1\?.dll;c:\program files\lua\5.1\\lib\lua\5.1\?.dll;
lua bridge-mpa-rest.lua
@ECHO "Pressione qualquer tecla para continuar ..."
@PAUSE
