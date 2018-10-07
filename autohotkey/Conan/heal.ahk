F1::Reload

F2::
Loop

{
pic1 := "C:\Users\Adam\Documents\MEGA\MEGAsync\Scripts\Games\Conan\health.bmp"
pic2 := "C:\Users\Adam\Documents\MEGA\MEGAsync\Scripts\Games\Conan\healthb.bmp"
pic3 := "C:\Users\Adam\Documents\MEGA\MEGAsync\Scripts\Games\Conan\regen.bmp"

Sleep, 1000

ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %pic2%

If(ErrorLevel == 0){

ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *80 %pic1%
If(ErrorLevel == 0){

ToolTip, Found , 0, 0

}else{


ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *80 %pic3%
If(ErrorLevel == 0){

ToolTip, Already regening, 0, 0

}else{

Send {8}

}

}else{

ToolTip, No Health Bar, 0, 0

}

}