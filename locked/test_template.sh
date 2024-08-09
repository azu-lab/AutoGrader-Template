#!/bin/bash

C_FILE=ex??_?.c
EXE_FILE=ex??_?

num_testcases=5

# local での test の場合はコンパイルせず既存のバイナリで実行
if [ $# -eq 1 ] && [ "$1" = "local" ]; then
    if [ ! -f "$EXE_FILE" ]; then
        echo "===== 結果: コンパイル失敗（バイナリファイルが見つかりません）====="
        echo ""
        exit 1
    fi
else
    # 通常のコンパイルプロセス
    gcc -o "$EXE_FILE" "$C_FILE"
    
    # コンパイルの成功を確認
    if [ $? -ne 0 ]; then
        echo "===== 結果: コンパイル失敗 ====="
        echo ""
        exit 1
    fi
fi

# 一時ファイルを作成
temp_output="./locked/temp_output.txt"
temp_error="./locked/temp_error.txt"
hash_output="./locked/hash_output.txt"

# 選択されたテストケースを実行
for idx in $(seq -w 0 $((num_testcases - 1))); do
    input="./locked/cases/${EXE_FILE}/in/$idx.txt"
    expect="./locked/cases/${EXE_FILE}/out/$idx.txt"
    "./$EXE_FILE" < $input > $temp_output 2> $temp_error
    echo $(cat $temp_output) | tr -d ' \t\n' | shasum -a 256 | awk '{print $1}' > $hash_output
    
    echo "テストケース: 入力: $(cat $input)"
    if [ -s "$temp_error" ]; then
        echo "===== 結果: エラー ====="
        echo "$(cat $temp_error)"
        echo ""
        rm "$temp_output" "$temp_error" "$hash_output"
        exit 1
    elif ! diff -q $expect $hash_output; then
        echo "===== 結果: 失敗 ====="
        echo "あなたの出力:"
        echo "$(cat $temp_output)"
        echo ""
        rm "$temp_output" "$temp_error" "$hash_output"
        exit 1
    fi
done

echo "===== 結果: 成功 ====="
echo ""

# 一時ファイルを削除
rm "$temp_output" "$temp_error" "$hash_output"