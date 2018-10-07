F3::
Send, {g}
Sleep, 250
ImageSearch, foundX, foundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, C:\Users\Adam\Pictures\zub.png
If(ErrorLevel == 0){
Send, {Ctrl Down}
Click right, %foundX%, %foundY%
Send, {Ctrl Up}	
}else{
;MsgBox, Image not found.
}
return