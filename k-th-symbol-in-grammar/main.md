779. K-th Symbol in Grammar
We build a table of n rows (1-indexed). We start by writing 0 in the 1st row. Now in every subsequent row, we look at the previous row and replace each occurrence of 0 with 01, and each occurrence of 1 with 10.
- For example, for n = 3, the 1st row is 0, the 2nd row is 01, and the 3rd row is 0110.
Given two integer n and k, return the kth (1-indexed) symbol in the nth row of a table of n rows.

Example 1:
Input: n = 1, k = 1
Output: 0
Explanation: row 1: 0

Example 2:
Input: n = 2, k = 1
Output: 0
Explanation: 
row 1: 0
row 2: 01

Example 3:
Input: n = 2, k = 2
Output: 1
Explanation: 
row 1: 0
row 2: 01

Constraints:
- 1 <= n <= 30
- 1 <= k <= 2^n - 1

Approach:
- よく遷移を観察すると、row(n)の前半はrow(n-1)になっている。ということはrowの長さがkを超えたらearly returnできそう
- forループでrowの長さがkを越えるまで 0->01, 1->10に置き換える操作をする

上記の方法の穴
- 時間計算量は、O(log k) < 30なので問題ないが、空間計算量がO(k)になるのでMLEになってしまう。
- Pythonでは文字列はimmutableなので置換操作にO(n)かかるので実際は時間計算量はもっと大きい

Give upし、AIに聞く
💡 空間計算量が大きいので、全てを計算せず n, kから逆算してピンポイントに文字を特定する方針にする

row(n - 1)からrow(n)を作る過程を考えると、k番目の文字に至るまでにすでに変換済みの2 * k文字が前にあることになる。つまりnのk番目はn - 1 の (kが偶数の時はk / 2, 奇数の時は k // 2 + 1)番目の文字を変換したもの。変換後は二文字になるので、kが偶数の時は変換後の後者、kが奇数の時は変換後の前者になる。これを愚直に書き、条件を整理したもの

- XORをとっているのは、parentと(k + 1) % 2を真理値表で書いて整理したもの
```py
class Solution:
    def kthGrammar(self, n: int, k: int) -> int:
        # nから逆算する。
        if n == 1:
            return 0

        parent = self.kthGrammar(n - 1, (k + 1) // 2)
        # XORをとる
        return parent ^ (k + 1) % 2
```

iterativeでも解いてみる。再帰と同じ順番になるようなやり方
```py
class Solution:
    def kthGrammar(self, n: int, k: int) -> int:
        stack = []
        while n > 1:
            stack.append((k + 1) % 2)
            k = (k + 1) // 2
            n -= 1

        # 戻りがけ：基底値から内側 -> 外側の順でXOR
        result = 0
        while stack:
            bit = stack.pop()
            result = result ^ bit
        return result
```

XORは**可換**なので、適用の順番は逆でも良い。stackに格納せずXORを適用する
- 親辿りの解法
```py
class Solution:
    def kthGrammar(self, n: int, k: int) -> int:
        result = 0
        while n > 1:
            bit = (k + 1) % 2
            # 可換なのでスタックを使わずbitの生成と同時に適用できる
            result ^= bit
            k = (k + 1) // 2
            n -= 1
        return result
```
- 別の再帰の解法
ex. n = 4, 01101001で、後半は前半のビット反転(0110 -> 1001)。行nの長さは2^(n-1)。
半分 half = 2^(n-2)。k番目がどっちにあるかで場合分け、
- 前半にある場合、row(n-1)のk番目にある
- 後半にある場合、row(n-1)を反転したものの(k - half)番目にある。
```py
class Solution:
    def kthGrammar(self, n: int, k: int) -> int:
        if n == 1:
            return 0
        
        half = 1 << (n - 2)
        if k <= half:
            return self.kthGrammar(n - 1, k)
        else:
            return 1 - self.kthGrammar(n - 1, k - half)
```

- iterativeで書き直す。kの値によって演算が変わるので戻りがけで選択できるようにフラグをstackに積む
```py
def kthGrammar(self, n, k):
    stack = []

    # 下り: 各ステップで「反転フラグ」を積みながら、引数を更新         
    while n > 1:
        half = 1 << (n - 2)                                            
        if k > half:           # 後半側                         
            stack.append(1)    # 反転すべき                         
            k -= half
        else:                  # 前半側                          
            stack.append(0)    # 反転しない                      
        n -= 1                                                      

    # 戻りがけ: 基底値から、内側 → 外側の順で適用                   
    result = 0                 # f(1, 1) の戻り値                 
    while stack:                             
        flip = stack.pop()
        if flip:                                 
            result = 1 - result                            
    return result
```

上記を簡略化する。result ^= flipとも書ける、さらにXORは可換なので下りで直接適用できる
```py
def kthGrammar(self, n, k):
    result = 0
    while n > 1:
        half = 1 << (n - 2)
        if k > half:
            # kが後半にある時はビットを反転する
            result ^= 1
            k -= half
        n -= 1                                     
    return result
```

他の解法
- 実はpopcountと同じ


## Step2

### popcount(k-1) % 2 になる本質的な説明
[olsen-blue#47](https://github.com/olsen-blue/Arai60/pull/47#discussion_r2003238004)
> あ、この問題もっとマクロな話をするとビットカウントの偶奇になっていますよ。二分木を考えて、右に行くとビットが反転して、左に行くとしないということですね。

> kの値にどう結びつくのかイメージできずでしたが、k-1 の二進数表記はルートからの移動パターンなんですね。
> k=5 (k-1=4, 二進数 100)だと、右(1)->左(0)->左(0)ですね。

二分木として捉え、`k-1` の2進表記が「根からの経路」になり、立っているビット数=反転回数。0-indexed (`k-1`) で考えるのが自然。
n=3 (row 3 = "0110") の二分木:
```
            0           ← row 1 (根)
           / \
       (左:同) (右:反転)
         /     \
        0       1       ← row 2
       / \     / \
   (左)(右) (左)(右)
      /\     /\
     0  1   1  0        ← row 3 (葉)
     ↑  ↑   ↑  ↑
   x=0 x=1 x=2 x=3      ← 0-indexed の葉番号 (= k-1)
   k=1 k=2  k=3 k=4     ← 問題の 1-indexed の k
```

| k | k-1 | 2進 | 経路 (0=左, 1=右) | 反転回数 | 値 |
|---|-----|-----|-------------------|---------|---|
| 1 | 0   | `00` | 左, 左 | 0 (偶) | 0 |
| 2 | 1   | `01` | 左, 右 | 1 (奇) | 1 |
| 3 | 2   | `10` | 右, 左 | 1 (奇) | 1 |
| 4 | 3   | `11` | 右, 右 | 2 (偶) | 0 |

→ 答え = `popcount(k - 1) % 2`

### `bin().count("1")` と `bit_count()` の内部実装の違い
[mamo3gr#44](https://github.com/mamo3gr/arai60/pull/44)
> `bin(self).count("1")` と同値、と書いてあるが、実装も一緒なんだろうか。どうやら違うみたい。`bin_count` は30bitごとにカウントする。

CPython の `int.bit_count()` は 30bit ごとにチャンクして処理する。clang/GCC では x86 の popcnt 命令を使う。それ以外では SWAR (SIMD Within A Register) アルゴリズムでカウント。

**popcnt とは**: population count の略で、ビット列の中で立っているビット (1) の個数を数える操作。Hamming Weight とも呼ばれる。x86 では SSE4.2 (2008, Intel Nehalem) で `POPCNT` 命令が追加され、1サイクルで計算できる。ARM の `CNT`、RISC-V の `cpop` など他アーキテクチャにも存在。CPU命令がない場合は SWAR (ビット並列に半分ずつ集約する古典的アルゴリズム) でソフトウェア計算する。

### Go の `bits.OnesCount` 内部実装と環境依存サイズの判定
[hroc135#44](https://github.com/hroc135/leetcode/pull/44)
> 32bitマシンか64bitマシンかどうかの調べ方が勉強になった
> `const uintSize = 32 << (^uint(0) >> 63)`
> `^uint(0)`は0のXORを取るので32bitマシンなら1が32個、64bitマシンなら64個並ぶ
> それを63個右シフトしたら32bitマシンなら全部0で、64bitマシンなら末尾に1が残る

`uint` のビット幅をマクロで判定する古典テクニック。`^uint(0)` で全ビット 1 → `>> 63` で MSB 残し → `32 << (0 or 1)` で 32 か 64 を出す。

### SWAR / Hamming Weight / popcnt
[hroc135#44](https://github.com/hroc135/leetcode/pull/44)
> SWAR Algorithm
> Hamming Weight を計算するアルゴリズム
> SWAR: SIMD within a Register
> 0x5555 -> 0101..., 0x3333 -> 00110011..., 0x0F0F -> 00010001...

CPU命令がない環境ではSWAR アルゴリズムでビット並列に半分ずつ集約していく。`__builtin_popcount` (C++) や `bits.OnesCount` (Go) はこれらの最適実装にフォールバックする。

**SWAR 実装 (32bit版)**:
```c
int popcount(uint32_t x) {
    x = x - ((x >> 1) & 0x55555555);          // 1: 2bitずつカウント
    x = (x & 0x33333333) + ((x >> 2) & 0x33333333);  // 2: 4bitずつ集約
    x = (x + (x >> 4)) & 0x0F0F0F0F;          // 3: 8bitずつ集約
    return (x * 0x01010101) >> 24;            // 4: 全部足す
}
```
🤖
各ステップの意味:
1. **2bit単位**: 隣接2ビットのペアごとに、立っているビット数(0,1,2)を2bit値として記録
2. **4bit単位**: 隣接2bitペアを足して、4bit値(0~4)に集約
3. **8bit単位**: 隣接4bit値を足して、8bit値(0~8)に集約
4. **最後の合計**: 4つの8bit値を全部足す。`x * 0x01010101` で「自分自身を4箇所にコピーしながら足す」のと等価で、その結果の上位8bitに合計が入るので `>> 24` で取り出す

ビット定数の意味:
- `0x55555555` = `0101 0101 ... 0101` (奇数番目のビットだけ1)
- `0x33333333` = `0011 0011 ... 0011` (2bitごとに 11 と 00)
- `0x0F0F0F0F` = `0000 1111 ... 0000 1111` (4bitごとに 1111 と 0000)

`O(log W)` ステップ (W = ビット幅) で popcount が求まる。条件分岐もループもないので CPU パイプラインを活かせて速い。

大学院受験の過去問で見たことがあるが理解はできていない

### 切り上げ除算の慣用句
[mamo3gr#44](https://github.com/mamo3gr/arai60/pull/44)
> `(k + 1) // 2`は切り上げ除算をしたいということだと思うので、意図を明確にするために`(k + 2 - 1) // 2`と書くのはありかと思いました。`//`を切り捨て除算の演算子として、`(被除数 + 除数 - 1) // 除数`で切り上げ除算になるという整数の離散性を使った公式ですね。

`ceil(a / b)` を整数演算で書くなら `(a + b - 1) // b`。`(k + 1) // 2` は `(k + 2 - 1) // 2` と書くと「2 で割って切り上げ」の意図が明示される。

### 反転の書き方の選択肢
[hroc135#44](https://github.com/hroc135/leetcode/pull/44)
> 好みですが、+1に何か意図があるように見えるので、反転処理は `1 - kthGrammar(n-1, k-rowSizeHalf)`と書く方が好きです。
> ちなみにPythonでは、not使うと反転できたんですが、bool 値になるため int 変換が必要になり、読みづらかったので、`1 - self.kthGrammar(n-1, k - half_num_elements)`って最終的に書きたくなりました。

0/1 の反転は `not x`（bool 化が必要）、`x ^ 1`（XOR）、`1 - x`（算術）の3択。`1 - x` は意図がもっとも明確で、`+1` のような副作用的な見た目がない。

### `if/else` vs 早期 return の使い分け
[hroc135#44](https://github.com/hroc135/leetcode/pull/44)
> 好みですが、等価なことを別々にやる時は if/else を使い、早期returnや特別な場合をキャッチするという時だけ if 単独で書きたい、みたいな気持ちがあります。

「2 つの対称的なパスを書くなら if/else、特殊ケースの早期脱出なら if 単独」というスタイルガイド。今回の問題のように「前半か後半か」という対称分岐なら if/else が読みやすい。

### 演算子優先順位の罠
[naoto-iwase#47](https://github.com/naoto-iwase/leetcode/pull/47)
> 単に置き換えても動かないように思います。bit に 1 より大きい値が xor されるためです。
> ```python
> target_bit = k & 1 << shift
> if target_bit != 0:
>     bit ^= 1
> ```

`k - 1 >> shift & 1` のような式は `<<`, `>>`, `&` の優先順位を覚えていないとバグる。Python では `<<` `>>` > `&` > `^` > `|` の順。`& 1` を最後に書いて 0/1 化を確実にする、または明示的に**括弧で囲む**のが安全。


### マクロな視点 vs ミクロな視点
[olsen-blue#47](https://github.com/olsen-blue/Arai60/pull/47)
> 解法1のミクロな視点より、解法2'のようにマクロの視点でA, Bブロックが見えている方が、なんか見晴らしが良い感じがする。

同じ問題でも:
- ミクロ（親子関係）: `f(n,k) = f(n-1, ceil(k/2)) ^ ((k+1)%2)`
- マクロ（A/Bブロック）: `f(n,k) = f(n-1,k)` (前半) or `1 - f(n-1, k-half)` (後半)

両方理解しておくと「行 n は行 n-1 のフラクタル展開」という構造が見える。

## Step3
マクロしてんのトップダウン半分割の解法で解く
💡 row(n)はrow(n-1)とそれを反転させたものを結合したものになる。

再帰で解いた後 -> iterativeに直してみる -> popcountを理解
```py
class Solution:
    def kthGrammar(self, n: int, k: int) -> int:
        # row nのk番目の数字を返す（1-indexed)
        if n == 1:
            return 0

        half = 2 ** (n - 2)
        if k <= half:
            return self.kthGrammar(n - 1, k)
        
        return 1 - self.kthGrammar(n - 1, k - half)
```

```py
class Solution:
    def kthGrammar(self, n: int, k: int) -> int:
        stack = []
        result = 0 # 再帰で最後にreturnする値
        while n > 1:
            half = 2 ** (n - 2)
            if k > half:
                # 再帰のreturn 1 - self.kthGrammar(n - 1, k - half)に対応
                result ^= 1 # 可換
                k -= half
            n -= 1
        
        return result
```