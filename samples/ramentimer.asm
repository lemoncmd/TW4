.section user
    out 0111    // LEDを3つ点灯
    swi         // 1分くらい待つ
    out 0110    // LEDを2つ点灯
    swi         // 1分くらい待つ
loop:
    out 0000    // LEDを滅
    out 0100    // LEDを点
    add a, 0001 // そして16回ループ
    jnc loop
    out 1000    // 端のLEDを点灯する
end:
    jmp end     // おわり（無限ループ）

.section swi
loop1:
    add a, 0001 // 16回ループ
    jnc loop1
loop2:
    add a, 0001 // また16回ループ
    jnc loop2
    iret        // 戻る
