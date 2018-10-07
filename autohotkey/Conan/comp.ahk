F3::
Click left, 340, 490
try := 0
While try <= 36
{
Click left, 340, 490
try += 1
pic := "C:\Users\Adam\Documents\MEGA\MEGAsync\Scripts\Games\Conan\conan-" . try . ".png"
Sleep, 100
ImageSearch, foundX, foundY, 270, 425, 1600, 1230, *10 %pic%
If(ErrorLevel == 0){
Click left, %foundX%, %foundY%
Sleep, 100
Send, {f}



}else{

}
if try = 12
{
Send {r}
Sleep, 100
Send {tab}
Sleep, 100
Send {tab}
Sleep, 100
Click left, 800, 310
Loop 10
    Click, WheelDown
}

if try = 21
{
Send {r}
Sleep, 100
Send {tab}
Sleep, 100
Send {tab}
Sleep, 100
Click left, 800, 310
Sleep, 100
Click left, 340, 490
Loop 18
    Click, WheelDown
}
if try = 24
{
Send {r}
Sleep, 100
Send {tab}
Sleep, 100
Send {tab}
Sleep, 100
Click left, 800, 310
Sleep, 100
Click left, 340, 490
Loop 18
    Click, WheelDown
}
if try = 36
{
#Persistent
ToolTip, Complete, 0, 0
SetTimer, RemoveToolTip, 3000
return

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

}
}

return
