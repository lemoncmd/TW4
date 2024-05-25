.section user
    in a        // レジスタAに数値を入力
    swi         // ソフトウェア割り込み
    mov b, a    // 出力用にレジスタBに移す
    out b       // 2倍された数値を出力
end:
    jmp end     // おわり（無限ループ）

.section swi
    swap        // レジスタAを通常モードから読みだす
    mov b, a    // b = a;
loop:           // while (1) {
    add a, 0001 //   a++;
    add b, 1111 //   b--;
    jnc end     //   if (b == 15) break;
    jmp loop    // }
end:
    add a, 1111 // a--;
    swap        // 通常モードのレジスタAに返す
    iret        // ハンドラを抜ける
