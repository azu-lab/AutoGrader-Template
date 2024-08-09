#!/bin/bash

# 課題番号を引数で受け取る
# ===== kadai_numbers ===== #

# all: すべてのテストを実行する
kadai_number=$1

# 引数がない場合
if [ -z $kadai_number ]; then
    echo "error: 課題番号を指定してください。"
    exit 1
fi

# 引数の数は1つのみ
if [ $# -ne 1 ]; then
    echo "error: 引数の数が間違っています。"
    exit 1
fi

# 引数が"all"以外の場合
if [ "$kadai_number" != "all" ]; then
    # 数値かどうかを判定
    expr "$kadai_number" + 1 > /dev/null 2>&1
    if [ $? -ge 2 ]; then
        echo "error: 引数は課題番号か'all'で指定してください。"
        exit 1
    fi
    # 数値が1以上の整数かどうかを判定
    if [ $kadai_number -lt 1 ] || [ $kadai_number -gt $kadai_numbers ]; then
        echo "error: 課題$kadai_numberは存在しません。"
        exit 1
    fi
fi
