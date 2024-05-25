.section user
    in b        // レジスタBに入力
loop:           // while (1) {
    out b       //   レジスタBを出力
    add b, 1111 //   b--;
    jnc end     //   if (b == 15) break;
    swi         //   1分くらい待つ
    jmp loop    // }
end:
    out 1111    // LEDを点
    out 0000    // LEDを滅
    jmp end     // の無限ループ（おわり）

.section swi
loop1:
    add a, 0001 // 16回ループ
    jnc loop1
loop2:
    add a, 0001 // また16回ループ
    jnc loop2
    iret        // 戻る
