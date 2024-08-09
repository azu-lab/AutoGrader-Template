# プログラミング演習 Ⅱ 第 ? 回

プログラミング演習の課題提出用のリポジトリ

## 今回の自動採点対象

<!-- ========== ここに今回の自動採点対象の課題の表を作成 ========== -->

> [!IMPORTANT]
> 自動採点対象に × が付いているものは TA・SA が手動で採点をするため、submit した際に番号が出ないが正常である。

## ローカルでのテスト方法

下記コマンドで c ファイルをコンパイル・実行する。scanf を用いたコードの場合は自身で値を入力して正しい結果を返すかを確認する。

```bash
# c ファイルをコンパイルして実行
gcc ex??_?.c -o ex??_?
./ex??_?

# 具体例（第 2 回の 3 つ目の課題の場合）
gcc ex02_3.c -o ex02_3
./ex02_3
```

コンパイルされた状態で以下コマンドを打つことで、実際のテストを実行出来る。

```bash
# 全ての課題のテストを実行
./test.sh all

# 特定の課題のテストを実行
./test.sh ${課題の番号}

# 具体例 (課題 1 つ目のテストを実行)
./test.sh 1
```

> [!WARNING]
> test.sh は、**提出前の確認用として用意している**ため、課題を進めている最中には実行しないこと。（原則上記の方法で挙動を確認する）

## 提出方法

下記コマンドを実行するとプログラムが提出され自動採点が開始される。

```bash
# 基本課題を提出
./submit.sh basic

# 発展課題を提出
./submit.sh advanced

# 全ての課題を提出
./submit.sh all
```

> [!IMPORTANT]
> ./submit.sh を実行する前には必ず./test.sh all を実行し、極力正解数が多い状態で提出すること。

また下記コマンドを実行すると、提出をせずに各自の最新の採点状況を確認することが出来る。

```bash
# 最新の採点結果を確認
./submit.sh status
```

> [!CAUTION]
> 課題の進行にあたり、以下の点に留意すること。これらの基準に違反した場合、課題の評価が 0 点とする可能性がある。
>
> - **locked ディレクトリ内や test.sh、submit.sh を編集しないこと**
> - **答えが一致している場合でも、課題に無関係なプログラムを作成しないこと**

<br><br>

### template 手順 (※ 以下は Class 作成後に消すこと)

※ make コマンドが使える環境を想定。使えない場合は以下を実行。

```bash
sudo apt install make
make --version
```

### 1. このリポジトリを Clone

clone した後に .git ディレクトリ配下を全削除し、新しく template リポジトリを立ててそこをリモートリポジトリとして登録。

### 2. make コマンドで template を展開

```bash
# ex{SESSION} で基本課題が BASIC 個、発展課題が ADCANVED 個のテンプレートを展開
make create_template SESSION=1 BASIC=1 ADVANCED=0
```

### 3. 模範解答の c ファイルをコピーしてセット

```c
// ex) ex01_1.c
#include <stdio.h>

int main(void)
{
    int n1, n2;

    printf("二つの整数を入力してください．\n");
    printf(" 整数 1: ");
    scanf("%d", &n1);
    printf(" 整数 2: ");
    scanf("%d", &n2);
    printf(" それらの和は %d です． \n", n1+n2);

    return 0;
}
```

### 4. テストの input をハンドメイドで作成

2 の工程で ./locked/cases/{ASSIGNMENT}/in というディレクトリに 0~5.txt が存在しているはずなので、そこにテストの入力情報を用意する。（必要に応じてテストを増やしたり減らしたり）

### 5. make コマンドで出力生成 & Hash 化

```bash
# ASSIGNMENT.c の出力を SHA-256 で Hash 化
make test_hash ASSIGNMENT=ex01_1
```

実行後に ./locked/cases/{ASSIGNMENT}/out の中に Hash 化されたテストケースがあれば完了。

> [!TIP]
> {ASSIGNMENT}\_test というディレクトリも同時に作成され、そこには Hash 化する前の出力結果が入っているので、必要に応じてその結果を違う場所に補完することをお勧めする。

### 6. C ファイルを生徒用に直す & 不要な情報を削除

1. README.md の template 作成手順以降
2. makefile
3. local_test_template.sh
4. locked/test_template.sh
5. locked/test_template_no_input.sh
6. test 生成時に出現する {ASSIGNMENT}\_test
7. c ファイルコンパイル時に生成されるバイナリ

> [!TIP]
> 6 は削除でなくディレクトリの外部に移しておくことを推奨

### 7. (任意) .gitignore の追加

```.gitignore
*
```

> [!TIP]
> 生徒の無駄なバイナリ push 防止として以下のような .gitignore を最後にコミットしてあげることを推奨。

### 8. README.md に自動採点対象の表を作成する

ex) 第 3 回演習の自動採点対象表

|     課題名     | ex03_1 | ex03_2 | ex03_3 | ex03_4 |
| :------------: | :----: | :----: | :----: | :----: |
| 自動採点の有無 |   ○    |   ○    |   ○    |   ○    |

## 補足

- あくまで template の為、output を違うものにしたい場合は自由にカスタマイズするので OK
- 以下を実行すると create_template を実行する前の環境まで戻る

```bash
make clear
```
