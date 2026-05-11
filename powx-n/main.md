50. Pow(x, n)
Implement pow(x, n), which calculates x raised to the power n (i.e., x^n).

Example 1:
Input: x = 2.00000, n = 10
Output: 1024.00000

Example 2:
Input: x = 2.10000, n = 3
Output: 9.26100

Example 3:
Input: x = 2.00000, n = -2
Output: 0.25000
Explanation: 2^-2 = 1/2^2 = 1/4 = 0.25
 
Constraints:
-100.0 < x < 100.0
-2^31 <= n <= 2^31-1
n is an integer.
Either x is not zero or n > 0. -> xは0ではないもしくはn > 0.
-10^4 <= x^n <= 10^4

エッジケース
- nがマイナス
- xがマイナス
- x = 0かつ n > 0

Approach
- n回かけようとするとかなり流石に計算量が大きすぎる
- 感覚的にO(logn)にできそうな感じがする
    - 2^10を例にする。2^10 = (2^5)^2, 2^5 = (2^2)^2 * 2
    こんな感じで分解が可能。

- 上記のエッジケースを網羅する

1回目のsubmitでTLEしたので、再帰関数にcacheデコレータをつけてAccept. 15分以内に解けた
```py
class Solution:
    def myPow(self, x: float, n: int) -> float:
        if x == 0:
            return 0

        @cache
        def my_pow_helper(n):
            if n == 0:
                return 1

            if n == 1:
                return x
            
            if n == -1:
                return 1 / x

            if n % 2 == 0:
                return my_pow_helper(n // 2) * my_pow_helper(n // 2)
            
            else:
                return my_pow_helper(n // 2) * my_pow_helper(n // 2) * x

        return my_pow_helper(n)       
```

AI🤖
> n = -3 のとき n // 2 = -2（Pythonの切り捨て除算）、残りは xを掛けていますが、負の奇数では 1/x を掛けるべきです. n = -3: n // 2 = -2, 残り = n - (n//2)*2 = -3 - (-4) = 1 → xを掛ける実はPythonの // は負の無限大方向に丸めるので -3 // 2 = -2 となり、-2 * 2 = -4、残りは +1 なので今回はたまたま正しく動きます。ただしこの挙動に暗黙に依存しているのは危険です。   

確かに、-3 // 2 = -2になってくれるので問題がないが、意識してなかったので危ない。暗黙の言語仕様で助かっているのはあまり良くないかも

> @cacheはfunctools.lru_cache(maxsize=None)のエイリアスで、メモリを無制限に使います。この問題ではO(logn)エントリなので実害はないですが、そもそもcacheが必要ない設計にできるのでcacheに頼るべきではありません 

- 1つ目の指摘については、nが負の時は符号を反転させて計算し、最後に戻す方法がある
- 2つ目について、cacheがあるとはいえ`return my_pow_helper(n // 2) * my_pow_helper(n // 2)`は2回同じ計算をしているので素直ではない。

改善
```py
class Solution:
    def myPow(self, x: float, n: int) -> float:
        if x == 0:
            return 0

        def my_pow_for_abs(n):
            assert n >= 0
            if n == 0:
                return 1

            if n == 1:
                return x

            half = my_pow_for_abs(n // 2)
            if n % 2 == 0:
                return half * half
            
            else:
                return half * half * x

        pow_abs = my_pow_for_abs(abs(n)) 
        return 1 / pow_abs if n < 0 else pow_abs
```

他の解法
- iterative版
    - ビットシフト

ビットシフトの解法。前提として n などはプログラム上では二進数扱いになっている
下位ビットからみるやり方。xを2乗していき、ビットが立っていたらresultにかける
nを2で割っていくのは右シフトをしている。
n=13だとすると、13=1101(2)
13 // 2 = 6 = 110(2)
6 // 2 = 3 = 11(2)
3 // 2 == 1(2)
```py
def myPow(self, x: float, n: int) -> float:
    if x == 0:
        return 0
    
    if n < 0:
        x = 1 / x
        n = -n
    
    result = 1
    while n > 0:
        if n % 2 == 1: # 最下位ビットが1である
            result *= x
        x *= x # xを二乗
        n //= 2
    return result
```

もう一つのやりかた
resultを2乗していき、ビットが立っていたらxをかける
```py
def myPow(self, x: float, n: int) -> float:
    if x == 0:
        return 0
    
    if n < 0:
        x = 1 / x
        n = -n
    result = 1
    for i in reversed(range(n.bit_length())):
        result *= result
        if (n >> i) & 1:
            # nは変更をせず、シフトする回数をインクリメントしている
            # ビットが立っている桁の時にxをかける
            result *= x
    return result
```
## Step2

### 0^0 は 1 か 0 か
[hroc135#43](https://github.com/hroc135/leetcode/pull/43) -> [コメント](https://github.com/hroc135/leetcode/pull/43/files#r2651608999)
> 0^0 は 1 のほうが自然に感じますね。空集合から空集合への射の数と考えるからです。

数学的には 0^0 は未定義だが、コンピュータサイエンスでは慣習的に 1 とすることが多い。LeetCodeの制約では `x != 0 or n > 0` なので 0^0 は入力されないが、標準ライブラリ（Go の math.Pow、Python の pow）は 1 を返す。

### IEEE 754 の内部ビット構成
[hroc135#43](https://github.com/hroc135/leetcode/pull/43) -> [コメント](https://github.com/hroc135/leetcode/pull/43/files#r2002313460)
> IEEE-754の内部ビットの数も覚えておくと、面接でよく分かっている風が醸せることがあります。exponent が8ビットと11ビットです。符号が1ビットで残りが23ビットと52ビットです。

- float32: 1(符号) + 8(指数) + 23(仮数) = 32, バイアス 127
- float64: 1(符号) + 11(指数) + 52(仮数) = 64, バイアス 1023
- exponentさえ覚えれば残りは計算で出せる

具体例: `3.14` を float64 で表現する
```
3.14 (10進) → 11.00100011110101110000... (2進、無限小数)
正規化:       1.100100011110101110000... × 2^1

符号部:  0                           （正の数）
指数部:  1 + 1023 = 1024 → 10000000000 （実際の指数にバイアス1023を足して格納）
仮数部:  1001000111101011100001...     （正規化後の小数点以下を52bit格納。先頭の1.は常に同じなので省略=ケチビット）
```

この問題で起きうるfloatの問題（IEEE 754準拠の言語すべてで共通: C++, Java, Go, Python, Rust等）
- **丸め誤差の蓄積**: 仮数52bitで打ち切るため掛け算1回ごとに誤差が発生する。O(n)で30回掛けるより、O(log n)で5回掛ける方が精度も良い。速さだけでなく精度の観点でもこの問題の解法は優れている
- **`x == 0` の比較**: IEEE 754では `+0.0` と `-0.0` が別のビット表現だが `==` では `True` になるので安全
- **アンダーフロー/オーバーフロー**: 極小値を繰り返し掛けるとfloatで表現できる最小値を下回り `0.0` に、極大値なら `inf` になりうる。この問題では制約 `-10^4 <= x^n <= 10^4` があるので発生しないが、一般的には注意

### n を破壊する vs bit変数を動かす（iterative版の可読性）
[TORUS0818#47](https://github.com/TORUS0818/leetcode/pull/47) -> [コメント](https://github.com/TORUS0818/leetcode/pull/47/files#r2031692691)
> n を破壊しているために関係が見にくくなっている

より読みやすい書き方:
```python
result = 1
bit = 1
base = x
while bit <= n:
    if n & bit:
        result *= base
    base *= base
    bit <<= 1
```
n を変更せず、`bit` を左シフトで動かしていく。変数の関係が明確で、デバッグもしやすい。自分のiterativeコードでも `n >>= 1` で n を破壊していたので参考になる。

### 再帰の同じ関数2回呼び出しは `** 2` で書ける
[TORUS0818#47](https://github.com/TORUS0818/leetcode/pull/47) -> [コメント](https://github.com/TORUS0818/leetcode/pull/47/files#r2038450416)
> 2 回同じ関数を同じ引数で呼び出すより、`return self.myPow(x, n // 2) ** 2` としたほうが分かりやすい

自分のコードでは `half` 変数に束縛する方法で解決したが、引数側で `x*x` にして渡す方法もある. これでも2回再帰関数が実行されることはない。
 `self.myPow(x**2, n // 2)`

### n が int の最小値 (-2^31) のとき -n でオーバーフロー
[TORUS0818#47](https://github.com/TORUS0818/leetcode/pull/47)
> C++だと n = -2^31 のときに符号を逆にするとsigned intではオーバーフローする

Pythonでは多倍長整数なので問題にならないが、C++/Java/Goなどでは `-n` が表現できない。対策として `n` を float に変換する方法がある。面接で言語差を聞かれたときに言及できると良い。
Pythonの多倍長整数の実装について
- 内部的に30bitごとの桁の配列として整数を持っている。
[30bit][30bit][30bit]
- pros: オーバーフローが起きない
- cons: 遅い。演算コストがO(桁数)以上。配列の各桁を処理するループになる。

### Pythonでの `n & 1` vs `n % 2`
[mamo3gr#43](https://github.com/mamo3gr/arai60/pull/43) -> [コメント](https://github.com/mamo3gr/arai60/pull/43/files#r2103930093)
> C++ ではときどき見かけるのですが、Python ではあまり見ない印象です。

Pythonではインタープリタを通すのでビット演算による速度向上はほぼない。可読性を優先して `n % 2` で良い。C++などではアセンブラとほぼ1:1対応するので `n & 1` が好まれる場面がある。

その他
- nが負の時、x^(-n)計算してから、1 / x^(-n)とするのか、x = 1 / xで置き換えるのかで浮動点小数の誤差の観点で少し違う
- 前者は掛け算n回分の誤差 + 除算１回分の誤差
- 後者は除算の誤差入りのxを掛け算n回で増幅

## Step3
iterativeのRight To Left版をかく
```py
class Solution:
    def myPow(self, x: float, n: int) -> float:
        if x == 0:
            return 0
        
        if n < 0:
            x = 1 / x
            n = -n
        result = 1
        base = x
        bit = 1
        while bit <= n:
            if n & bit:
                result *= base
            base *= base
            bit <<= 1 # 左シフトすることで上位ビットを見ていく
        return result
```