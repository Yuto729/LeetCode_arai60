6. ZigZag Conversion

The string "PAYPALISHIRING" is written in a zigzag pattern on a given number of rows like this: (you may want to display this pattern in a fixed font for better legibility)

P   A   H   N
A P L S I I G
Y   I   R
And then read line by line: "PAHNAPLSIIGYIR"
Write the code that will take a string and make this conversion given a number of rows:
string convert(string s, int numRows);

Example 1:
Input: s = "PAYPALISHIRING", numRows = 3
Output: "PAHNAPLSIIGYIR"

Example 2:
Input: s = "PAYPALISHIRING", numRows = 4
Output: "PINALSIGYAHRPI"
Explanation:
P     I    N
A   L S  I G
Y A   H R
P     I

Example 3:
Input: s = "A", numRows = 1
Output: "A"

Constraints:
- 1 <= s.length <= 1000
- s consists of English letters (lower-case and upper-case), ',' and '.'.
- 1 <= numRows <= 1000


## Step1
（紆余曲折ありAcceptできたので以下に考え方を整理する）

まずは例1で考える。文字列のそれぞれの文字に番号を振って考える(0-indexedにすればindexと同じ)
sのインデックス0 ~ 13に対して、conversionは以下のように表せる。

0   4   8    12
1 3 5 7 9 11 13
2   6   10

結果を格納する配列を, numRows * 1の空配列として、各行に値を追加していくことでConversionを構築することとする。(この結果配列を`result`とする)
sを一文字ずつ走査してどの行に追加できるか考えてみる。上の図にて、進む方向は "上 -> 下"もしくは"左下 -> 右上"しかない。前者について考えてみると、前者のようなパスで追加される配列のインデックスには法則がある。
つまりkを整数として、`2k * (row - 1) <= i < (2k + 1)(row - 1)`を満たすiは上->下のパスにて走査される要素である。上->下ということは行番号が増加する方向ということ。上記の範囲では行番号を増加させながら`result[r]`に値を追加していく。
上記の範囲が終わったら、`(2k + 1) * (row - 1) <= i < (2k + 2)(row - 1)`の範囲は下->上のパスなので、行番号が減少する方向である。同じように要素を追加する。

言語化があまり上手くない....

45分くらいかかってしまった
- numRows = 1のガードが抜けていた

Time: O(N)
Space: O(N)
```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1:
            return s
            
        rows = [[] for _ in range(numRows)]
        r = 0
        k = 0
        i = 0
        while i < len(s):
            while 2 * k * (numRows - 1) <= i < min((2 * k + 1) * (numRows - 1), len(s)):
                rows[r].append(s[i])
                i += 1
                r += 1
            while (2 * k + 1) * (numRows - 1) <= i < min(2 * (k + 1) * (numRows - 1), len(s)):
                rows[r].append(s[i])
                i += 1
                r -= 1
            k += 1
        
        result = ""
        for r in rows:
            result += "".join(r)
        
        return result
```

AIに聞いて簡略化のヒントを得る。
> 行番号 r を +1/-1で振動させる発想（端で反転）にすれば、kや範囲計算なしで一重ループで書けます

```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1:
            return s
            
        rows = [[] for _ in range(numRows)]
        r = 0
        is_r_increasing = True
        for ch in s:
            rows[r].append(ch)
            if r == numRows - 1:
                is_r_increasing = False
            if r == 0:
                is_r_increasing = True

            if is_r_increasing:
                r += 1
            else:
                r -= 1

        result = ""
        for r in rows:
            result += "".join(r)
        
        return result
```
- ひとまずフラグを使って書いてみたが、もう少し簡単にならないか
    - 単に方向を変数として持っておけば良さそう

- 冒頭の `if numRows == 1`はforループ内での冗長な条件分岐をあらかじめ回避するための特殊ケース
```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1:
            return s
            
        rows = [[] for _ in range(numRows)]
        r = 0
        # rを進める方向
        direction = 1
        for ch in s:
            rows[r].append(ch)
            if r == numRows - 1:
                direction = -1
            if r == 0:
                direction = 1
            
            r += direction

        result = ""
        for r in rows:
            result += "".join(r)
        
        return result
```

## Step2

### 他の解法: cycle解法（数式で行を直接求める）
direction加算ではなく、サイクルの周期性から各文字の行を直接計算する解法。

```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1:
            return s

        rows = [[] for _ in range(numRows)]
        cycle = 2 * (numRows - 1)
        for i, ch in enumerate(s):
            pos = i % cycle
            r = pos if pos < numRows else cycle - pos
            rows[r].append(ch)
        return "".join("".join(row) for row in rows)
```

- 周期 `2 * (numRows - 1)` の中で前半は下り（行 = pos）、後半は上り（行 = cycle - pos）。
- 状態（direction）を持たないので関数型/ジェネレータ的に書きやすい。
- 反面「折り返し」を式で表す必要があり、direction加算より読み手の負荷は高め。
- 派生として `itertools.batched(s, cycle)` で周期ごとのチャンクに分けて処理する解法もある。

---

### `+=` による文字列連結のコスト（Pythonのimmutable）
[olsen-blue#61](https://github.com/olsen-blue/Arai60/pull/61#discussion_r2040670667)
> 最適化されるかもしれませんが、pythonでは文字列はimmutableなので、最適化されなければこの処理のたびに毎回新しいオブジェクトが作り直されるであろう部分は気になりました

Pythonの`str`はimmutable。`s += ch` はループでO(N²)になりうる。CPythonでは、最適化がされるらしいが、バージョンや環境によるかもしれない。読み手にとってもわかりやすいのは`"".join()`方式

cf. [cpython unicodeobject.c](https://github.com/python/cpython/blob/bb3e0c240bc60fe08d332ff5955d54197f79751c/Objects/unicodeobject.c#L11768-L11775), [cpython issue #99862](https://github.com/python/cpython/issues/99862)

### 文字列のmutability比較（C++/Java/Python）と Rope
[Ryotaro25#66](https://github.com/Ryotaro25/leetcode_first60/pull/66#discussion_r2020118072)
> Java や Python など文字列が immutable な言語では重要な話ですが、C++ では、mutable で後ろに文字をつける分には大きな問題になりません。前後に付けたり分割したりなどする必要があるならば、Rope というデータ構造などを使えばいいです

C++の`std::string`はmutableなのか. Ropeというのは初めて聞いた

### 性能改善は「秒」で具体化する（パレート最適）
[Ryotaro25#66](https://github.com/Ryotaro25/leetcode_first60/pull/66#discussion_r2020118072)
> 100人で会議をします、弁当の予算はいくら必要ですか、と聞かれて「人数に比例する額です」以上の答えが出てこなかったらやばいやつ

- 最適化の議論をするなら定量的に見積もる.

> 最低限、「パレート最適」、つまり、何かを改善しようとすると、何かが悪くなる、くらいにはよいコードを書きたいです。その中では比較的、コードの複雑さ(code complexity) が優先される事が多いです。
読みやすく、問題があったときにデバッグしやすく、修正しやすいのか、つまり、すべてのコードは未来においてマイナスを生み出しうるが、それは小さいのか、ということです。

### 内包表記をネストする / generator expression
[saagchicken#22](https://github.com/saagchicken/coding_practice/pull/22)
> ```return "".join(c for line in display_board for c in line)```

generator expression -> `(x*x for x in range(10**6))`のように丸括弧で囲むとGeneratorになる。上記で、二次元配列を展開しているところがややこしいが、"c, for each line in board, for each c in line"と読むと理解しやすい

- `"".join("".join(row) for row in rows)` より一段スッキリ。
- `join` の引数はリストである必要はなくiterableで良い。
- generator式にすると中間リストを作らずメモリ節約（[PEP 289](https://peps.python.org/pep-0289/)）。
ただし「ネスト内包は認知負荷が高い」という反対意見もあり（[Mike0121#26](https://github.com/Mike0121/LeetCode/pull/26)）

- `list.extend` → `"".join` の方が generator expression より速いというベンチ結果もある（[naoto-iwase#61](https://github.com/naoto-iwase/leetcode/pull/61)）
    - `list.extend`はCPythonで高速だけど、GeneratorはPython側で__next__を逐一呼ぶから？

### 手続き型で組み合わせる出題意図
[saagchicken#22](https://github.com/saagchicken/coding_practice/pull/22)
> この問題、出題意図は、お手玉できるか、な気もします。
Generator は内部的には、ある種のコンテキストを持っていて、計算の続きに戻れるようにしています。だから、それなりに重いです。
そういうわけで、手続き型の手法で構造を組み合わせられるかが想定だろうなと思います。

### early return のチューニング
[naoto-iwase#61](https://github.com/naoto-iwase/leetcode/pull/61)
> len(s) <= numRows: return sは、空配列を余計に作らないで済むパターンのearly return。

`numRows == 1` だけでなく `len(s) <= numRows` のときも入力をそのまま返せる（zigzagの最初の縦列で全部収まる）。

---

## Step3
```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1 or len(s) <= numRows:
            return s

        direction = 1
        r = 0
        rows = [[] for _ in range(numRows)]
        for c in s:
            rows[r].append(c)
            if r == numRows - 1:
                direction = -1
            elif r == 0:
                direction = 1
            r += direction
        
        result = []
        for row in rows:
            result.extend(row)
        
        return "".join(result)
```