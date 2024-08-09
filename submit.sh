# githubにpushするためのスクリプト
# Usage: ./submit.sh

# 基本課題ファイルリスト
#===== BASIC_TARGET_FILES =====#

# 発展課題ファイルリスト
#===== ADVANCED_TARGET_FILES =====#

# コミットメッセージ
#===== COMMIT_MESSAGE =====#

# 引数が1つであり、かつその引数が "basic", "advanced", "stauts" ではない場合にスクリプトを終了
if ! ([ $# -eq 1 ] && ([[ "$1" == "basic" ]] || [[ "$1" == "advanced" ]] || [[ "$1" == "all" ]] || [[ "$1" == "status" ]])) ; then
    echo "Error: 引数が間違っています"
    exit 1
fi

# status の場合
if [[ "$1" == "status" ]]; then
    echo "採点結果：" $(gh run view $(gh run list -L 1 --json 'databaseId' --jq '.[0].databaseId') --log | grep "Total:" | awk -F '│' '{print $3}'  | sed 's/0//g')
    exit 0
fi

# 引数が all の場合、TARGET_FILESに基本と発展のファイルを含める
TYPE=$(echo "$1" | tr '[:lower:]' '[:upper:]')
if [[ "$1" == "all" ]]; then
    TARGET_FILES=("${BASIC_TARGET_FILES[@]}" "${ADVANCED_TARGET_FILES[@]}")
else
    TARGET_FILES="${TYPE}_TARGET_FILES"
    TARGET_FILES=( $(eval echo \${$TARGET_FILES[@]}) )
fi

COMMIT_MESSAGE+=" ($TYPE)"

# リモートリポジトリの設定
REMOTE_REPOSITORY="origin"
BRANCH_NAME="main"

# ファイルの追加
# 変更があるかどうかを確認
change_check=0
for file in ${TARGET_FILES[@]}; do
    git add $file
    changes=$(git status --porcelain $file)
    if [ -n "$changes" ]; then
        change_check=1
    fi
done

# 変更がない場合は何もしない
if [ $change_check -eq 0 ]; then
    echo "変更がありません。"
    exit 0
fi

# commit & push
git commit -m "$COMMIT_MESSAGE"
git push $REMOTE_REPOSITORY $BRANCH_NAME

# 採点中のメッセージ
echo -n "課題を提出しました。採点中"

for i in {1..10}; do
    echo -n "."
    sleep 1
done

# statusがcompletedになるまで待機
while true; do
    echo -n "."
    status=$(gh run list -L 1 --json 'status' --jq '.[0].status')
    if [ $status = 'completed' ]; then
        break
    fi
    sleep 1
done
echo ""

# 最近実行されたワークフローの一覧をJSON形式で取得し、その中から最初のワークフローのIDを取得する
run_id=$(gh run list -L 1 --json 'databaseId' --jq '.[0].databaseId')

# 結果を表示しない課題番号を指定
basic_num=${#BASIC_TARGET_FILES[@]} #基本課題の数
advanced_num=${#ADVANCED_TARGET_FILES[@]} #発展課題の数
if [[ "$1" == "basic" ]]; then 
    NO_TARGETS=$(seq $((basic_num + 1)) $((basic_num + advanced_num)))
elif [[ "$1" == "advanced" ]]; then
    NO_TARGETS=$(seq 1 $basic_num)
fi
PATTERN=$(echo $NO_TARGETS | sed 's/ /|/g')

if [ -n "$PATTERN" ]; then
    # PATTERNがある場合はsedで処理する
    PATTERN=$(echo "$PATTERN" | sed 's/ /|/g')
    sed_cmd="sed 's/[$PATTERN]//g'"
else
    # PATTERNがない場合は何もしない
    sed_cmd="cat"
fi

# 採点結果を表示
echo "採点結果：" $(gh run view $run_id --log | grep "Total:" | awk -F '│' '{print $3}'  | sed 's/0//g' | eval "$sed_cmd")
exit 0
