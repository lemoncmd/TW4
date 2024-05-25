.section user
    imsk 0001   // 割り込み有効化
loop:
    mov a, 0000 // 当たり判定リセット
    out 1000
    out 0100
    out 0010
    mov a, 0001 // 玉の当たり判定始め
    out 0001
    add a, 1111 // 玉が当たったか判定
    jnc loop    // 当たらなければ終わり
end:
    out 1010
    out 0101
    jmp end

.section irq
    mov a, 0    // ボタンを押したら通常モードのレジスタAを0にする
    swap        // 当たり判定の取得
    add a, 1111
    jnc ret     // 当たれば跳ね返す描写
    out 0010
    out 0100
ret:
    iret
