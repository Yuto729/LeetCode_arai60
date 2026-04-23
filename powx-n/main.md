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