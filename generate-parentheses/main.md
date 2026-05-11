Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.

Example 1:
Input: n = 3
Output: ["((()))","(()())","(())()","()(())","()()()"]

Example 2:
Input: n = 1
Output: ["()"]
 
Constraints:
- 1 <= n <= 8

## Step1
手作業でどのように行うか考える。open = '(', close = ')'とする。n=3のとき
まず初めはopenでないといけない。その次はopen, closeどちらでもよく、openは３個まで積むことができる。closeが使えるのは、openの個数よりもcloseの個数が少ないときかつ、openの個数が3個以下のとき。openの個数が3個のときはcloseしか使えず、closeも3個積まれたら一つの組みが完成する。

上記をまとめる。各ステップにてopen, closeの分岐が現れるが、それは下記の条件に従って決まる。

- openの個数 = nかつcloseの個数 < n -> closeしか使えない
- openの個数 < n かつ openの個数 > closeの個数 -> open, closeどちらも使える
- openの個数 < n かつ openの個数 = closeの個数 -> openしか使えない
組みを全て求めるので、バックトラックをしながら全組みを求めていく。


約15分。2回ほど提出し直した。
- open_count, close_countをnonlocalにしておらず参照ができなかった
- 引数にすることで修正したが、二番目のif文内で直接open_countを編集していたことで、3つ目のif文に影響が出てしまった。

Time: O(mn) m = 有効な文字列の総数
Space: O(n)

```py
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        open_bracket = "("
        close_bracket = ")"
        result = []
        parentheses = []
        def backtrack(open_count, close_count):
            if open_count == close_count and open_count == n:
                result.append("".join(parentheses))
                return
            
            # 上記の条件を整理し、下記の2つに
            if open_count < n:
                parentheses.append(open_bracket)
                backtrack(open_count + 1, close_count)
                parentheses.pop()
            
            if open_count > close_count:
                parentheses.append(close_bracket)
                backtrack(open_count, close_count + 1)
                parentheses.pop()
        
        backtrack(0, 0)
        return result
```

🤖review
> 1. 終了条件は close_count == n で十分 `if open_count == close_count and open_count == n:`
不変条件として常に open_count >= close_count かつ open_count <= nなので、close_count == nだけで等価です。条件が短くなり意図が伝わりやすい。

確かに条件は簡素になるが、不変条件に関するパズルがあるようでわかりにくくも感じる
- `parentheses` -> `path`, `current`などでも良さそう
- 総数mはカタラン数 m=C_n ~~ 4^n / n^(3/2)らしい

iterativeに書き換える
- 時間・空間計算量が増える -> O(m * n^2)に
```py
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        result = []
        stack = [(0, 0, "")]
        while stack:
            open_count, close_count, parentheses = stack.pop()
            if open_count == close_count and open_count == n:
                result.append("".join(parentheses))
                continue

            if open_count < n:
                stack.append((open_count + 1, close_count, parentheses + "("))
            if open_count > close_count:
                stack.append((open_count, close_count + 1, parentheses + ")"))

        return result
```

DP (Closure Number DP)で解く
n=3を例に考える。
((())) -> ( (()) ) + ""
(()()) -> ( ()() ) + ""
(())() -> ( () ) + ()
()(()) -> ( ) + (())
()()() -> ( ) + ()()
一番外側の(に対応する、)の位置で必ず分割できる。任意のwell-formedな文字列sは、s = "(" + A + ")" + Bというように書ける。
A, Bも独立してwell-formed
全体がnペアなので、Aがiペア使ったらBはn - i - 1ペアになる。これを踏まえると漸化式を作ることができる。
なぜ上記の分割が正しいか？ -> 「最初の(に対応する)」は一位に決まる(balanceが初めて0に戻る位置)ので同じ文字列は二度作らない。
全列挙ではなく、個数だけならDPが一番良い。


```py
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        # dp[i] = i ペアで作れる全 well-formed 文字列
        # 漸化式: 任意の s ∈ dp[i] は "(" + a + ")" + b に一意分解できる
        # a ∈ dp[j], b ∈ dp[i-1-j], j ∈ [0, i-1]
        dp = [[] for _ in range(n + 1)]
        dp[0] = [""]
        for i in range(1, n + 1):
            for j in range(i):
                for inner in dp[j]:
                    for rest in dp[i - j - 1]:
                        dp[i].append("(" + inner + ")" + rest)
        
        return dp[n]
```
- inner, rest -> inside, outsideでも

Length DP
長さ0 ~ 2nまで、長さごとに有効な部分文字列を保持して伸ばす
```py
class Solution:                                                          
    def generateParenthesis(self, n: int) -> List[str]:
        # 各 (open, close) 状態ごとに到達する文字列を保持
        # dp[o][c] = open_count=o, close_count=c になる全文字列
        dp = [[[] for _ in range(n+1)] for _ in range(n+1)] 
        dp[0][0] = [""]
        for total in range(1, 2*n + 1):
            for o in range(n+1):
                c = total - o
                if c < 0 or c > n or c > o: continue
                # ( から来る
                if o > 0:
                    for s in dp[o-1][c]:
                        dp[o][c].append(s + "(")
                # ) から来る
                if c > 0:
                    for s in dp[o][c-1]:
                        dp[o][c].append(s + ")")
        return dp[n][n]
```
- 状態空間で考えるDP。Closure Number版と違って「左から1文字ずつ」のDP 化。
- 空間: 中間状態を全部保持するので大きい

## Step2

https://discord.com/channels/1084280443945353267/1225849404037009609/1232382815849414656
```py
完成品 = []
残りタスク = [("", n, n)]
while 残りタスク:
    作成中, 左の残り, 右の残り = 残りタスク.pop()
```
> ここまで読んだ時点で、generateParenthesis するために、「作成中, 左の残り, 右の残り」を使って DFS するんだろうという予想が立ち、「作成中」が文字列、「左の残り, 右の残り」が数であることは分かりますね。なんで、これそんなにパズルじゃないのですよ。

[fhiyo#53](https://github.com/fhiyo/leetcode/pull/53#discussion_r1714595621)
> 無理に省略するのではなく`parenthesis`とかにしてあげたほうが読みやすいかなと思います。

[nittoco#43](https://github.com/nittoco/leetcode/pull/43)
> unclosed_left_countのほうが意味がわかると思います / 確かに修飾語は前にあったほうがわかりやすいですね

`open_count` よりも意味を明示する `unclosed_left_count` のような命名。修飾語は前置の方が英語的にも自然。

https://github.com/wf9a5m75/leetcode3/pull/2
> 私の名前の気持ちは、left, right よりも、inside, outside ですが趣味の範囲です。

(A)B分解での命名。「左/右」より「内側/外側」の方が構造を表現している。

### Closure Number 再帰 — 「(A)B」という分類
[olsen-blue#54](https://github.com/olsen-blue/Arai60/pull/54#discussion_r2022389382)
> はじめの括弧とそれに対応する括弧に注目して「(A)B」と分けるのも分類ですね。

```py
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        if n == 0:
            return [""]
        result = []
        for i in range(n):
            for A in self.generateParenthesis(i):
                for B in self.generateParenthesis(n - 1 - i):
                    result.append("({}){}".format(A, B))
        return result
```
バックトラックを「お片付け」ではなく「分類の網羅」として捉える視点。1文字目の `(` に対応する `)` の位置で全解を一意に分類できる(balanceが初めて0に戻る位置)ので、トップダウンに `(A)B` で再帰分解できる。Closure Number DPと同じ発想。

### 文字列構築のコストとカタラン数の構造
[skypenguins#27](https://github.com/skypenguins/coding-practice/pull/27)
> parents + "("で逐次文字列の再構築が走るので時間計算量で不利になると思います。Pythonドキュメント：「イミュータブルなシーケンスの結合は、常に新しいオブジェクトを返します...シーケンスの長さの合計の二次式になる」

> 計算量が不利になるか怪しいと思います。カタラン数を生成する木の中間ノードの各層の数なんですが、ballot numbers などといわれるものの和で表せます。最終層から a 層戻ったときの減り方の極限は (a/2+1)^2 / 2^a なので、最後の数層のコピー以外はほとんど効かないんですね。

カタラン数の木構造では「最終層が支配的」で、上位層のコピーは幾何級数的に減衰するためほぼ効かない。直感的に「str+strは二次式コスト」と思いがちだが、ballot numberの分布を考えると影響は数倍程度。

実測ベンチ：
```
 n    str+str  list+list  pair  
 8    1.17ms   1.59ms     2.68ms
10   13.57ms  21.91ms    35.23ms
```
**str+strが最速**。文字列のコピーはネイティブコード(SIMD/loop unroll)で動くため、Pythonの list操作より100倍速い。

[fhiyo#53](https://github.com/fhiyo/leetcode/pull/53#discussion_r1714137722)
> n かかっているのが join によるコピーなので、ネイティブコードで走っているでしょうから500クロックはかからない感じがしますね。

計算量(漸近的)と実測時間は別物。Pythonでは「インタプリタ層の操作 vs ネイティブ層の操作」の定数倍差が桁違い。

### 高階関数で文字列構築自体を遅延する解法
[hroc135#50](https://github.com/hroc135/leetcode/pull/50#discussion_r2052246310) / Discord
```py
@cache
def generate_functions_to_append_parenthesis(n):
    if n == 0:
        return [lambda sb: None]
    result = []
    for i in range(n):
        for a in generate_functions_to_append_parenthesis(i):
            for b in generate_functions_to_append_parenthesis(n - i - 1):
                def fn(sb, a=a, b=b):
                    sb.append("("); a(sb); sb.append(")"); b(sb)
                result.append(fn)
    return result
```
部分問題の結果として「文字列」ではなく「StringBuilderへ追記する関数」をキャッシュする。`@cache` で部分構造の関数を共有でき、最終生成時のみ文字列化する。Closure Number DPの**遅延評価版**。
- 中間でstring化しないのでコピーコストが発生しない
- クロージャのデフォルト引数(`a=a, b=b`)で**late binding問題**を回避している点に注目

### Generator (yield from) と認知負荷
[fhiyo#53](https://github.com/fhiyo/leetcode/pull/53#discussion_r1717017646)
> 自分が読み慣れていないだけだと思うのですが、 yield from を用いたソースコードは、認知負荷が高いように感じました。

https://github.com/fhiyo/leetcode/pull/53#discussion_r1717116155
> generatorはリストと異なりメモリにその内容を同時にすべて載せないというメモリ効率性のメリット。実務ではインターフェースは変更できる想定で書いています。

https://github.com/fhiyo/leetcode/pull/53#discussion_r1717215096
> yield fromが悪いというよりは、`map(lambda s: ')' + s, ...)` の部分との組み合わせが読みにくい。

### functools.cache の落とし穴
https://discord.com/channels/1084280443945353267/1252267683731345438/1252591437485441024
> functools.cache は候補ですが、破壊されるとどうしましょうか。標準マニュアルは読んでおきましょう。

`@functools.cache` でリストを返すと**呼び出し元が破壊するとキャッシュごと壊れる**。tupleを返すかimmutableに保つ必要がある。型annotationも合わせて。

### バックトラック=分類の網羅という見方
[olsen-blue#54](https://github.com/olsen-blue/Arai60/pull/54#discussion_r2021145424)
> バックトラックは、お片付けという見方しかできていませんでした。分類という新たな見方を教えてくださりありがとうございます。

バックトラックの本質は「**全解空間を漏れなく分類する**」こと。
- 1文字ずつ追加: 「次の1文字が ( か ) か」で分類
- (A)B 分解: 「最初の ( に対応する ) の位置」で分類
- () + ()()+...: 「最初の独立な括弧グループの長さ」で分類

> 一つのやり方として、1文字ずつ開きか閉じかを追加していくというのがありますね。他に、開き+閉じ\*(0~ここまでの開きの数までのどれか)までを一つの仕事とみる仕事の分担方法もある。色々あるので、オプションは見ておきたい。最後のゴールは、選択肢を見たうえで、10分程度でスクラッチから書き上げられること。

「お片付け」(append/pop) は実装上の都合であって、本質は分類の網羅。この視点を持つと「子分に丸投げ」(再帰)の発想が自然になる。

#### bitmaskで文字列を符号化する最適化
[naoto-iwase#54](https://github.com/naoto-iwase/leetcode/pull/54) 参考
```py
# bit 1 -> "(", bit 0 -> ")"
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        def to_parentheses(bit_mask):
            parentheses = []
            for shift in range(2 * n - 1, -1, -1):
                # シフト演算の方がニ項ビット演算より優先度が高いが、一応()をつける
                if (bit_mask >> shift) & 1:
                    parentheses.append("(")
                else:
                    parentheses.append(")")

            return "".join(parentheses)
            
        result = []
        stack = [(0, 0, 0)] # (open_count, close_count, bit_mask)
        while stack:
            open_count, close_count, bit_mask = stack.pop()
            if open_count + close_count == 2 * n:
                result.append(to_parentheses(bit_mask))
                continue

            next_mask = bit_mask << 1
            if open_count < n:
                stack.append((open_count + 1, close_count, next_mask + 1))
            if open_count > close_count:
                stack.append((open_count, close_count + 1, next_mask))
    
        return result
```
2nビットのintで括弧列を表現し、最後にだけ文字列化する。
- stack変更時のlist/strの結合コスト(O(n))が **bit shift (O(1))** に
    - Time: O(mn), Space: O(mn)
- ただしn=8 (16bit)なら有効だが、長いとbignum演算で逆に遅くなる
- カタラン数のエンコーディング/ranking問題と接続(前述のballot number)

#### 終了条件の別表現
[mamo3gr#50](https://github.com/mamo3gr/arai60/pull/50)
> 終了条件について、自分は `num_opens == num_closes == n` としていたが、`len(parentheses) == 2 * n` も成り立つ。なるほど。

`len(path) == 2*n` も等価な終了条件。不変条件の代わりに**長さ**で判定する視点。条件のバリエーション：
- `close_count == n` (最短、不変条件依存)
- `open == close == n` (現状、冗長だが安全)
- `len(path) == 2*n` (長さ視点、深さ優先で考える時に自然)

#### itertools.product で意図を伝える
[mamo3gr#50 step2_dp.py](https://github.com/mamo3gr/arai60/pull/50)
```py
@functools.cache
def generateParenthesis(self, n: int) -> list[str]:
    if n == 0: return [""]
    all_parentheses = []
    for i in range(n):
        for A, B in itertools.product(
            self.generateParenthesis(i), self.generateParenthesis(n - 1 - i)
        ):
            all_parentheses.append(f"({A}){B}")
    return all_parentheses
```
3重forより `itertools.product` の方が「**直積**を取りたい」意図が伝わる。`@functools.cache` を**メソッド**につけるとselfがハッシュキーに入るので、Solution クラスのインスタンスが共有されないと効かないことに注意(LeetCodeはテストごとに new するので一応動く)。

### カタラン数 (Catalan Number)とは
- https://manabitimes.jp/math/657
```
C_n = (1 / (n+1)) * C(2n, n) = (2n)! / ((n+1)! * n!) Cはコンビネーション
```
漸化式：
```
C_0 = 1
C_n = Σ_{i=0}^{n-1} C_i * C_{n-1-i}
```
数列: `1, 1, 2, 5, 14, 42, 132, 429, 1430, ...` (n=8で1430)
漸近: `C_n ~ 4^n / (n^(3/2) * √π)`

#### カタラン数が現れる問題(全部同じ構造)
上記の漸化式で遷移が表される。

- **Generate Parentheses**: n ペアのwell-formed括弧列の数
- **二分木の形の数**: n ノードの形の異なる二分木 (LeetCode 95, 96)
- **Dyck path**: 対角線を超えない格子路の数
- **凸多角形の三角形分割**: (n+2)角形の分割方法
- **行列連鎖積の括弧付け**: n+1 個の行列の括弧の入れ方
- **スタック並び替え**: 1〜n の push/pop 順序の数

## Step3
recursive backtrackで解く
- 残数視点で書いてみる
```py
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        result = []
        path = []
        def generate(open_remain, close_remain):
            if open_remain == 0 and close_remain == 0:
                result.append("".join(path))
                return
            
            if open_remain > 0:
                path.append("(")
                generate(open_remain - 1, close_remain)
                path.pop()
            
            if close_remain > open_remain:
                path.append(")")
                generate(open_remain, close_remain - 1)
                path.pop()
        
        generate(n, n)
        return result
```
## 類題
- [17. Letter Combinations of a Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/)
- [39. Combination Sum](https://leetcode.com/problems/combination-sum/)
- [46. Permutations](https://leetcode.com/problems/permutations/)
- [78. Subsets](https://leetcode.com/problems/subsets/)
- [79. Word Search](https://leetcode.com/problems/word-search/)
- [51. N-Queens](https://leetcode.com/problems/n-queens/)