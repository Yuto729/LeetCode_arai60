# 121. Best Time to Buy and Sell Stock
## Step1
You are given an array prices where prices[i] is the price of a given stock on the ith day.
You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.
Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.
 
Example 1:
Input: prices = [7,1,5,3,6,4]
Output: 5
Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.
Note that buying on day 2 and selling on day 1 is not allowed because you must buy before you sell.

Example 2:
Input: prices = [7,6,4,3,1]
Output: 0
Explanation: In this case, no transactions are done and the max profit = 0.

Example 3:
Input: prices = [1]
Output: 0

Constraints:
- 1 <= prices.length <= 10^5
- 0 <= prices[i] <= 10^4

Approach
- 利益を得られないときは0とあるが、負も含めて得られる最大の利益を計算し、最後に0とのmaxを取れば良さそう
- ナイーブに解くとするとi日目で買って、j日目で売るのを全探索し、最大を計算する。時間計算量はO(n^2)になる
- 上記についてj日目で売りたいとすると、買うのはそれ以前で一番安いときにしたい。
    - 暫定で一番安いときと利益の最大値を変数にし、pricesを前から順に走査すればO(n)で解ける

Accept
```py
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        if not prices:
            return 0
        
        max_profit = 0
        min_price = prices[0]
        for price in prices[1:]:
            max_profit = max(max_profit, price - min_price)
            min_price = min(min_price, price)
        
        return max(max_profit, 0)
```
- よく考えると、最後maxを取る必要がない（max_profitを0で初期化しているため）

## Step2 他の人のコードやコメントを読む

- https://discord.com/channels/1084280443945353267/1206101582861697046/1219181674038820945
> prices が空の場合は、何を返すことが想定されているでしょうか。
⁠leetcode_colorbox⁠
⁠leetcode_ahayashi⁠
これはどう答えてもいい問題です。
ただ、if not prices: の処理を先頭に書くことにすると、
INT_MAX などを使わずに、prices[0] が使えるようになります。

---

- `prices[1:]` スライスはメモリコピーが発生する
([naoto-iwase#42](https://github.com/naoto-iwase/leetcode/pull/42#discussion_r1870000000), [mamo3gr#35](https://github.com/mamo3gr/arai60/pull/35))
> `prices[1:]` はリストのスライスを新規作成するので、微小ながら無駄なメモリを使います。インデックスで 1 から回すか、`math.inf` 初期化で全要素を一度に処理するとより素直です。

`itertools.islice(prices, 1, None)` を使えばコピーなしにスライスと同等の走査ができる。CPythonの実装レベルでもコピーが発生しない。

- `if`分岐 vs `min`/`max` のトレードオフ
([naoto-iwase#42](https://github.com/naoto-iwase/leetcode/pull/42#discussion_r1870000001), [mamo3gr#35](https://github.com/mamo3gr/arai60/pull/35))

mamo3grさんの実測（Python 3.14, n=100,000, 1000試行）:
```
min/max:   5.67 秒
if:        2.77 秒
Itertools: 5.69 秒
```
`min_price`更新時はmax_profit更新不要なので `if-continue` の方が約2倍速い。ただしPython使用時点で誤差の範囲とも言える。

Leetcodeの実行時間計測でも確かに何回やっても数倍速くなる

- 型ヒントは引数をabstractに、返り値をspecificに
([naoto-iwase#42](https://github.com/naoto-iwase/leetcode/pull/42#discussion_r1870000002))
> 引数の type hint はより abstract に（`Sequence`や`Iterable`）、返り値はより specific にすることが多い。
> Python 3.9以降は `List` ではなく built-in `list` を使う。

- https://docs.python.org/3/library/typing.html#typing.List
> Note that to annotate arguments, it is preferred to use an abstract collection type such as Sequence or Iterable rather than to use list or typing.List.

---

- `itertools.accumulate` でHaskell風に書く
([goto-untrapped#58](https://github.com/goto-untrapped/Arai60/pull/58#discussion_r1670000000), [naoto-iwase#42](https://github.com/naoto-iwase/leetcode/pull/42))

Haskellの本質的な表現:
```haskell
prices = [2,4,6,1,3,5]
-- scanl f init list -> 初期値からはじめてfを累積適用した途中経過をすべて返す
minPrices = scanl min (prices!!0) prices  -- そこまでの最小値列
-- zipwith -> 2つのリストを対応する要素ごとに関数で合成する
profit = zipWith (-) prices minPrices     -- 各日の利益
-- fold f init list -> 畳み込み。リストを左から畳み込んで最大値を求める。
maxProfit = foldl max 0 profit
```
- 参考: https://docs.python.org/3/library/itertools.html
> This module implements a number of iterator building blocks inspired by constructs from **APL, Haskell, and SML**. Each has been recast in a form suitable for Python.
`itertools`モジュール自体がHaskell/APL/SMLに着想を得て設計されている。

Pythonでの対応:
```python
from itertools import accumulate

class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        """scanl min -> zipWith (-) -> maximum"""
        prefix_mins = accumulate(prices, min)   # scanl1 min
        profits = (p - m for p, m in zip(prices, prefix_mins))
        return max(profits)
```

- 3状態のステートマシンとして捉える
([コメント in naoto-iwase#42](https://github.com/naoto-iwase/leetcode/pull/42#discussion_r1870000003))
> 「買う前の状態」「株を持っている状態」「売った状態」の3状態しかないので、それぞれの状態での最大の所持金（スタートを0とする）を考える。

```python
cash_before_buy = 0
cash_holding = float("-inf")
cash_after_sell = 0

for price in prices:
    cash_holding = max(cash_holding, cash_before_buy - price)
    cash_after_sell = max(cash_after_sell, cash_holding + price)

return max(0, int(cash_after_sell))
```
この問題の場合、1回しか買えないので、`cash_before_buy`は常に0. 整理すると一番最初の解法とと同じこと

- 後ろから走査する別解
([irohafternoon#40](https://github.com/irohafternoon/LeetCode/pull/40))
`highest_price_ever` を後ろから持ち回ることで `numeric_limits<int>::max()` 不要・初期値を0にできる:
```cpp
int highest_price_ever = 0;
for (int i = prices.size() - 1; i >= 0; i--) {
    highest_price_ever = std::max(highest_price_ever, prices[i]);
    max_profit = std::max(max_profit, highest_price_ever - prices[i]);
}
```

---

### その他

- x86/ARMのCMOV命令でmax/minが分岐なしに実行される
([コメント in irohafternoon#40](https://github.com/irohafternoon/LeetCode/pull/40#discussion_r2084763958))
> x86では LEA で取ってきて SUB で引き算。max/min については `CMOVcc` という命令があって、CMP で比較した後のフラグで代入の有無を決められます。よって10命令以下で回りそう。（ARMは `CSEL`）

- 1ループ10命令以下で回るなら1計算ステップ = クロック周波数(つまりCppの場合は10^9)と見積もっても良さそうということ

ちなみにC++での本問題のO(n)ループは実測で1要素あたり0.84ナノ秒（irohafternoonさん計測）。
理論値を考えると、3GHz(3*10^9クロック)のCPUなら1クロック≒0.33ns。1要素あたり複数命令（LEA, SUB, CMOVcc×2）が必要なので、「1命令1クロック」の仮定では1要素数ns以上かかるはず。しかし実測0.84nsはそれを下回っている。

これはスーパースカラ（1クロックで複数命令を並列実行）が効いているためと考えられる(?)。`CMOVcc` で分岐がないため分岐予測ミスによるパイプラインフラッシュが起きず、CPUが命令を滞りなく並列投入できる状態になっている。

- 変数名 `lowest_price_ever` について
([コメント in irohafternoon#40](https://github.com/irohafternoon/LeetCode/pull/40#discussion_r2080000000))
> `lowest_price_ever` って変数名いいですね！真似したいです。

`min_price` より意図（過去最安値）が明確に伝わる。
- `so_far`とか`ever`は使えそう

---

## Appendix: アセンブリ・パフォーマンス分析

### ソースコードと実行コマンド

```cpp
// maxprofit.cpp / bench.cpp（ベンチは main() を追加）
#include <vector>
#include <algorithm>
#include <cstdlib>

int maxProfit(const std::vector<int>& prices) {
    if (prices.empty()) return 0;
    int max_profit = 0;
    int min_price = prices[0];
    for (int i = 1; i < (int)prices.size(); i++) {
        max_profit = std::max(max_profit, prices[i] - min_price);
        min_price = std::min(min_price, prices[i]);
    }
    return max_profit;
}

// bench.cpp のみ
int main() {
    std::vector<int> prices(100000);
    for (int i = 0; i < 100000; i++) prices[i] = rand() % 10000;
    volatile int result = 0;
    for (int t = 0; t < 1000; t++) result = maxProfit(prices);
    return result;
}
```

```bash
# アセンブリ生成
g++ -O2 -S -o maxprofit.s maxprofit.cpp

# ベンチビルド & perf実行
g++ -O2 -o bench bench.cpp
sudo sysctl kernel.perf_event_paranoid=-1
perf stat ./bench
```

### 生成されたアセンブリ（gcc -O2）

```asm
.L4:
    movl  (%rdx), %ecx      # prices[i] をレジスタecxに読み込む
    movl  %ecx, %edi        # ediにコピー
    subl  %eax, %edi        # edi = prices[i] - min_price (eax=min_price)
    cmpl  %edi, %esi        # max_profit(esi) と (prices[i]-min_price) を比較
    cmovl %edi, %esi        # max_profitを更新（less なら移動 = max）
    cmpl  %ecx, %eax        # min_price(eax) と prices[i](ecx) を比較
    cmovg %ecx, %eax        # min_priceを更新（greater なら移動 = min）
    addq  $4, %rdx          # ポインタを次の要素へ
    cmpq  %r8, %rdx         # ループ終端チェック
    jne   .L4               # 続けるなら戻る
```

`std::max`/`std::min` は `cmovl`/`cmovg` に最適化されており、ループ本体は10命令以下。`jne` はループカウンタの分岐で毎回同じ方向に分岐するため予測精度はほぼ100%。
[cmovcc document](https://www.felixcloutier.com/x86/cmovcc)

### perf stat 結果（n=100,000, 1000試行）
```
cpu_core/instructions/  1,065,450,465   3.85 insn per cycle
cpu_core/branch-misses/         4,661   0.00% of all branches
```

- **IPC = 3.85**：1クロックに平均3.85命令を並列実行 → スーパースカラが効いている
- **branch-miss = 0.00%**：`CMOVcc` により分岐予測ミスがほぼゼロ

### 考察

9命令/イテレーション ÷ IPC3.85 ≈ 2.3クロック/イテレーション。これがスーパースカラによる並列実行で実現できている。「1命令1クロック」の仮定（IPC=1）なら9クロック/イテレーションのところ、実際は2.3クロックで回っている。
`CMOVcc` で分岐がなくパイプラインが詰まらない状態を作ることで、CPUが命令を並列投入しやすくなっている。分岐なし（CMOVcc）とスーパースカラは独立した最適化だが、組み合わさって効いている。